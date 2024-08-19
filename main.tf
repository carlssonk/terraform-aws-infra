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
  depends_on  = [time_sleep.wait_5_seconds]
}

data "aws_iam_policy_document" "bucket_policy" {
  statement {
    actions = [
      "s3:CreateBucket",
      "s3:ListBucket",
      "s3:GetBucketLocation",
      "s3:ListAllMyBuckets",
      "s3:HeadBucket"
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
  name        = "terraform-execution-policy"
  description = "Composite policy for Terraform execution role"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = concat(
      jsondecode(data.aws_iam_policy_document.bucket_policy.json).Statement,
    )
  })
}

resource "aws_iam_role_policy_attachment" "terraform_execution_policy" {
  role       = "terraform-execution-role"
  policy_arn = aws_iam_policy.terraform_execution_policy.arn
}

# Add a time_sleep resource
resource "time_sleep" "wait_5_seconds" {
  depends_on = [aws_iam_policy.terraform_execution_policy, aws_iam_role_policy_attachment.terraform_execution_policy]
  create_duration = "5s"
}
