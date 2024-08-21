variable "table_name_full" {}

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

module "create_and_attatch_policy" {
  source = "../../iam"
  name = "dynamodb"
  policy_document = data.aws_iam_policy_document.this.json
}