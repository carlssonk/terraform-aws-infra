variable "name" {}
variable "policy_document" {}

data "aws_iam_policy" "existing" {
  name = "terraform-${var.name}-policy"
  count = 0
}

locals {
  existing_policy = try(data.aws_iam_policy.existing[0].policy, "")
  policy_exists = length(local.existing_policy) > 0
}

data "aws_iam_policy_document" "new" {
  source_policy_documents = [var.policy_document]
}

data "aws_iam_policy_document" "merged" {
  source_policy_documents = compact([
    local.policy_exists ? local.existing_policy : null,
    data.aws_iam_policy_document.new.json
  ])
}

resource "aws_iam_policy" "this" {
  name        = "terraform-${var.name}-policy"
  description = "Composite policy for Terraform execution role"
  policy      = data.aws_iam_policy_document.merged.json

  # Use lifecycle rule to ignore changes to the description
  lifecycle {
    ignore_changes = [description]
  }
}

resource "aws_iam_role_policy_attachment" "this" {
  role       = "terraform-execution-role"
  policy_arn = aws_iam_policy.this.arn
}