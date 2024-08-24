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
  count   = module.globals.run_iam
  backend = "s3"
  config = {
    bucket = "${module.globals.var.organization}-terraform-state-bucket-${terraform.workspace}"
    key    = "iam/terraform.tfstate"
    region = module.globals.var.region
  }
}

locals {
  // If cleanup_policies is true we ignore previous policies
  previous_policy_document = module.globals.var.cleanup_policies ? [] : try(data.terraform_remote_state.previous[0].outputs.current_policy_document, [])
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
  count  = module.globals.run_iam
  name   = "terraform-${var.name}-policy"
  policy = jsonencode(local.current_policy_document)
}

resource "aws_iam_role_policy_attachment" "attachment" {
  count      = module.globals.run_iam
  role       = "terraform-execution-role"
  policy_arn = aws_iam_policy.policy[0].arn
}

output "current_policy_document" {
  value       = local.current_policy_document
  description = "The current set of policies, including both old and new"
}

