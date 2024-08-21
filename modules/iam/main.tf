variable "name" {}
variable "policy_document" {}

data "aws_iam_policy" "existing" {
  name = "terraform-${var.name}-policy"
}

locals {
  policy_exists = data.aws_iam_policy.existing.arn != ""
}

data "aws_iam_policy_document" "merged" {
  source_policy_documents = [
    local.policy_exists ? data.aws_iam_policy.existing.policy : null,
    var.policy_document
  ]
}

resource "aws_iam_policy" "this" {
  name        = "terraform-${var.name}-policy"
  description = "Composite policy for Terraform execution role"
  policy      = data.aws_iam_policy_document.merged.json

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_iam_role_policy_attachment" "this" {
  role       = "terraform-execution-role"
  policy_arn = aws_iam_policy.this.arn
}