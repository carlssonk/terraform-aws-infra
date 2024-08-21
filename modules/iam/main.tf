variable "name" {}
variable "policy_documents" {}

locals {
  combined_policy = {
    Version = "2012-10-17"
    Statement = flatten([
      for doc in var.policy_documents : jsondecode(doc).Statement
    ])
  }
}

resource "aws_iam_policy" "policy" {
  name   = "terraform-${var.name}-policy"
  policy = jsonencode(local.combined_policy)
}

resource "aws_iam_role_policy_attachment" "attachment" {
  role       = "terraform-execution-role"
  policy_arn = aws_iam_policy.policy.arn
}