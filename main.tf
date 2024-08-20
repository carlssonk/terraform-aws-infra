variable "environment" {}
variable "region" {}
variable "organization" {}
variable "run_infrastructure" { default = false }
variable "run_permissions" { default = false }

terraform {
  backend "s3" {}
}

module "portfolio" {
  count = var.run_infrastructure ? 1 : 0
  source = "./apps/portfolio"
  environment = var.environment
  organization = var.organization
}

data "aws_iam_policy_document" "bucket_policy" {
  count = var.run_permissions ? 1 : 0
  statement {
    actions = [
      "s3:CreateBucket",
      "s3:DeleteBucket",
      "s3:ListBucket",
      "s3:ListAllMyBuckets",
      "s3:HeadBucket",
      "s3:Put*",
      "s3:Get*"
    ]
    resources = ["arn:aws:s3:::*"]
    effect = "Allow"
  }
  statement {
    actions = ["s3:*"]
    resources = [
      "arn:aws:s3:::carlssonk-terraform-state-bucket-prod",
      "arn:aws:s3:::carlssonk-terraform-state-bucket-prod/*"
    ]
    effect = "Allow"
  }
}

resource "aws_iam_policy" "terraform_execution_policy" {
  count = var.run_permissions ? 1 : 0
  name = "terraform-execution-policy"
  description = "Composite policy for Terraform execution role"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = concat(
      jsondecode(data.aws_iam_policy_document.bucket_policy[count.index].json).Statement,
    )
  })
}

resource "aws_iam_role_policy_attachment" "terraform_execution_policy" {
  count = var.run_permissions ? 1 : 0
  role = "terraform-execution-role"
  policy_arn = aws_iam_policy.terraform_execution_policy[count.index].arn
}