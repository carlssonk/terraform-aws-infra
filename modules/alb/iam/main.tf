module "globals" {
  source = "../../../globals"
}

data "aws_iam_policy_document" "this" {
  statement {
    actions = concat(
      [
        "elasticloadbalancing:*LoadBalancer*",
        "elasticloadbalancing:*Listener*",
        "elasticloadbalancing:*Certificates*",
        "elasticloadbalancing:Describe*",
        "elasticloadbalancing:CreateRule"
      ],
    )
    resources = [
      "arn:aws:elasticloadbalancing:${module.globals.var.aws_region}:${module.globals.var.aws_account_id}:loadbalancer/app/${var.name}-alb/*",
      "arn:aws:elasticloadbalancing:${module.globals.var.aws_region}:${module.globals.var.aws_account_id}:listener/app/${var.name}-alb/*"
    ]
    effect = "Allow"
  }

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

  statement {
    actions = concat(
      [
        "elasticloadbalancing:Describe*"
      ],
    )
    resources = ["*"]
    effect    = "Allow"
  }
}
