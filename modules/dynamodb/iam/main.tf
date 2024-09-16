module "globals" {
  source = "../../../globals"
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
      "arn:aws:dynamodb:::${module.globals.var.ORGANIZATION}-${var.table_name}-${terraform.workspace}",
      "arn:aws:dynamodb:::${module.globals.var.ORGANIZATION}-${var.table_name}-${terraform.workspace}/*"
    ]
    effect = "Allow"
  }
}
