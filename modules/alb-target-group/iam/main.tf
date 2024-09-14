data "aws_iam_policy_document" "this" {
  statement {
    actions = concat(
      [
        "elasticloadbalancing:CreateLoadBalancer",
        "elasticloadbalancing:DeleteLoadBalancer",
        "elasticloadbalancing:RegisterInstancesWithLoadBalancer",
        "elasticloadbalancing:RegisterTargets",
        "elasticloadbalancing:DeregisterInstancesFromLoadBalancer",
        "elasticloadbalancing:DeregisterTargets",
        "elasticloadbalancing:*Listener",
        "elasticloadbalancing:*TargetGroup",
        "elasticloadbalancing:Describe*",
        "elasticloadbalancing:Modify*",
        "elasticloadbalancing:CreateRule",
        "iam:CreateServiceLinkedRole"
      ],
    )
    resources = ["*"]
    effect    = "Allow"
  }
}
