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
  depends_on  = [null_resource.policy_update]
}

data "aws_iam_policy_document" "bucket_policy" {
  statement {
    actions = [
      "s3:CreateBucket",
      "s3:ListBucket",
      "s3:GetBucketLocation",
      "s3:ListAllMyBuckets",
      "s3:HeadBucket",
      "s3:GetBucketPolicy"
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
resource "null_resource" "policy_update" {
  triggers = {
    policy_id = aws_iam_policy.terraform_execution_policy.id
    attachment_id = aws_iam_role_policy_attachment.terraform_execution_policy.id
  }

  provisioner "local-exec" {
    command = "sleep 30"
  }
}
