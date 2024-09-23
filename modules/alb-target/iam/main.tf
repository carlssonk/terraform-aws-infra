module "globals" {
  source = "../../../globals"
}

data "aws_iam_policy_document" "this" {
  statement {
    actions = concat(
      [
        "elasticloadbalancing:*Rule*",
        "elasticloadbalancing:*Target*",
      ],
    )
    resources = [
      "arn:aws:elasticloadbalancing:${module.globals.var.aws_region}:${module.globals.var.aws_account_id}:listener-rule/app/*",
      "arn:aws:elasticloadbalancing:${module.globals.var.aws_region}:${module.globals.var.aws_account_id}:targetgroup/*"
    ]
    effect = "Allow"
  }
}
