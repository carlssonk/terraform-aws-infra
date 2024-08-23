variable "table_name_full" {
  description = "Name of dynamodb table prefixed with organization and suffixed with environment"
  type        = string
}

data "aws_iam_policy_document" "this" {
  statement {
    actions = concat(
      [
        "dynamodb:CreateTable",
        "dynamodb:DeleteTable",
        "dynamodb:Get*",
        "dynamodb:List*",
        "dynamodb:Describe*"
      ]
    )
    resources = [
      "arn:aws:dynamodb:::${var.table_name_full}",
      "arn:aws:dynamodb:::${var.table_name_full}/*"
    ]
    effect = "Allow"
  }
}

output "policy_document" {
  value = data.aws_iam_policy_document.this.json
}
