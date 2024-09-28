data "aws_region" "current" {}
data "aws_caller_identity" "current" {}

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
      "arn:aws:elasticloadbalancing:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:loadbalancer/app/${var.name}-alb/*",
      "arn:aws:elasticloadbalancing:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:listener/app/${var.name}-alb/*"
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
      "arn:aws:acm:eu-north-1:${data.aws_caller_identity.current.account_id}:certificate/*"
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

output "policy_document" {
  value = try(data.aws_iam_policy_document.this.json, null)
}
