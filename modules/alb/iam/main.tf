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
      ],
    )
    resources = [
      "arn:aws:elasticloadbalancing:${module.globals.var.AWS_REGION}:${module.globals.var.AWS_ACCOUNT_ID}:loadbalancer/app/${var.name}-alb/*",
      "arn:aws:elasticloadbalancing:${module.globals.var.AWS_REGION}:${module.globals.var.AWS_ACCOUNT_ID}:listener/app/${var.name}-alb/*"
    ]
    effect = "Allow"
  }
}
