variable "workflow_step" {}

variable "name" {
  description = "Policy name"
  type        = string
}

variable "policy_documents" {
  description = "List of policy documents"
  type        = list(string)
}

module "globals" {
  source = "../globals"
}

data "terraform_remote_state" "previous" {
  backend = "s3"
  config = {
    bucket = "${module.globals.var.organization}-terraform-state-bucket-${terraform.workspace}"
    key    = "env:/${terraform.workspace}/iam/terraform.tfstate"
    region = module.globals.var.region
  }
}

locals {
  previous_policy_document = tobool(module.globals.var.cleanup_policies) ? [] : try([data.terraform_remote_state.previous.outputs["${var.name}_policy"]], [])
  policies                 = distinct(concat(local.previous_policy_document, var.policy_documents))

  // Below logic groups all resources together that have the same permissions

  // Maps out the statement for each policy
  merged_statements = flatten([
    for policy in local.policies :
    try(jsondecode(policy).Statement, [])
  ])

  // Groups all identical keys (effect + actions), statement... tells Terraform to create a list of values  when multiple items have the same key
  grouped_statements = {
    for statement in local.merged_statements :
    "${lower(statement.Effect)}-${jsonencode(sort([for action in tolist(statement.Action) : lower(action)]))}" => statement...
  }

  // Loops over each group and collects all resources
  combined_statements = [
    for key, statements in local.grouped_statements : {
      Effect   = statements[0].Effect
      Action   = statements[0].Action
      Resource = distinct(flatten([for s in statements : s.Resource]))
    }
  ]

  current_policy_document = {
    Version   = "2012-10-17"
    Statement = local.combined_statements
  }
}

resource "aws_iam_policy" "policy" {
  count  = var.workflow_step == "iam" ? 1 : 0
  name   = "terraform-${var.name}-policy"
  policy = jsonencode(local.current_policy_document)
}

resource "aws_iam_role_policy_attachment" "attachment" {
  count      = var.workflow_step == "iam" ? 1 : 0
  role       = "terraform-execution-role"
  policy_arn = aws_iam_policy.policy[0].arn
}

output "policy_document" {
  value = jsonencode(local.current_policy_document)
}
