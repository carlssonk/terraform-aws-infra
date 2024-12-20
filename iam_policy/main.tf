module "globals" {
  source = "../globals"
}

data "aws_region" "current" {}

data "terraform_remote_state" "previous" {
  count   = var.workflow_step == "iam" ? 1 : 0
  backend = "s3"
  config = {
    bucket = "${module.globals.var.organization}-terraform-state-bucket-${terraform.workspace}"
    key    = "env:/${terraform.workspace}/iam/terraform.tfstate"
    region = data.aws_region.current.name
  }
}

locals {
  previous_policy_document = tobool(module.globals.var.cleanup_policies) ? [] : try([data.terraform_remote_state.previous[0].outputs.policy_documents[var.name]], [])
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
    "${lower(statement.Effect)}-${jsonencode(sort(
      [for action in(
        can(tolist(statement.Action)) ? tolist(statement.Action) : [tostring(statement.Action)]
      ) : lower(action)]
    ))}" => statement...
  }

  // Loops over each group and collects all resources
  combined_statements = [
    for key, statements in local.grouped_statements : {
      Effect   = statements[0].Effect
      Action   = statements[0].Action
      Resource = distinct(flatten([for s in statements : s.Resource]))
    }
  ]

  policy_document_result = {
    Version   = "2012-10-17"
    Statement = local.combined_statements
  }
}

resource "aws_iam_policy" "policy" {
  count  = var.workflow_step == "iam" ? 1 : 0
  name   = "terraform-${var.name}-policy"
  policy = jsonencode(local.policy_document_result)
}

resource "aws_iam_role_policy_attachment" "attachment" {
  count      = var.workflow_step == "iam" ? 1 : 0
  role       = "terraform-execution-role"
  policy_arn = aws_iam_policy.policy[0].arn
}
