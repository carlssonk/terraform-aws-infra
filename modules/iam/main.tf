variable "name" {}
variable "policy_document" {}

data "aws_iam_policy" "existing_policy" {
  name  = "terraform-${var.name}-policy"
}

locals {
  existing_policy = try(data.aws_iam_policy.existing_policy.policy, "{}")
  new_policy      = var.policy_document
  
  existing_policy_doc = jsondecode(local.existing_policy)
  new_policy_doc      = jsondecode(local.new_policy)
  
  merged_statements = distinct(concat(
    try(local.existing_policy_doc.Statement, []),
    try(local.new_policy_doc.Statement, [])
  ))
  
  merged_policy = jsonencode({
    Version   = "2012-10-17"
    Statement = local.merged_statements
  })
}

resource "aws_iam_policy" "policy" {
  name   = "terraform-${var.name}-policy"
  policy = local.merged_policy

   lifecycle {
    create_before_destroy = true
  }
}

resource "aws_iam_role_policy_attachment" "attachment" {
  role       = "terraform-execution-role"
  policy_arn = aws_iam_policy.policy.arn
}