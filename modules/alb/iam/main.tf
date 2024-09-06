

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
        "iam:CreateServiceLinkedRole"
      ],
    )
    resources = ["*"]
    effect    = "Allow"
  }
}

output "policy_document" {
  value = data.aws_iam_policy_document.this.json
}
