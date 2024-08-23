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

locals {
  workflow_step = module.globals.var.workflow_step
  combined_policy = {
    Version = "2012-10-17"
    Statement = flatten([
      for doc in var.policy_documents : try(jsondecode(doc).Statement, null)
    ])
  }
}

resource "aws_iam_policy" "policy" {
  count  = module.globals.run_iam
  name   = "terraform-${var.name}-policy"
  policy = jsonencode(local.combined_policy)
}

resource "aws_iam_role_policy_attachment" "attachment" {
  count      = module.globals.run_iam
  role       = "terraform-execution-role"
  policy_arn = aws_iam_policy.policy[0].arn
}
