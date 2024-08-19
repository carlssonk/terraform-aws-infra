variable "environment" {}
variable "region" {}
variable "organization" {}

terraform {
  backend "s3" {}
}

module "portfolio" {
  source = "./apps/portfolio"
  environment = var.environment
  organization = var.organization
}

resource "aws_iam_policy" "terraform_execution_policy" {
  name        = "terraform-execution-policy"
  description = "Composite policy for Terraform execution role"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = concat(
      jsondecode(module.portfolio.bucket_policy_json).Statement,
    )
  })
}

resource "aws_iam_role_policy_attachment" "terraform_execution_policy" {
  role       = "terraform-execution-role"
  policy_arn = aws_iam_policy.terraform_execution_policy.arn
}