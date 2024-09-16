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
      "arn:aws:elasticloadbalancing:${module.globals.var.AWS_REGION}:${module.globals.var.AWS_ACCOUNT_ID}:listener-rule/app/*",
      "arn:aws:elasticloadbalancing:${module.globals.var.AWS_REGION}:${module.globals.var.AWS_ACCOUNT_ID}:targetgroup/*"
    ]
    effect = "Allow"
  }

  statement {
    actions = concat(
      [
        "elasticloadbalancing:DescribeTargetGroups",
      ],
    )
    resources = ["*"]
    effect    = "Allow"
  }
}
