module "globals" {
  source = "../../../globals"
}

data "aws_iam_policy_document" "this" {
  statement {
    actions = concat(
      [
        "acm:*Certificate"
      ]
    )
    resources = [
      "arn:aws:acm:eu-north-1:${module.globals.var.aws_account_id}:certificate/*"
    ]
    effect = "Allow"
  }
}
