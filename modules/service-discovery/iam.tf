data "aws_region" "current" {}
data "aws_caller_identity" "current" {}

data "aws_iam_policy_document" "this" {
  statement {
    actions = concat(
      [
        "servicediscovery:DeleteNamespace",
        "servicediscovery:GetNamespace",
        "servicediscovery:UpdatePrivateDnsNamespace",
        "servicediscovery:CreatePrivateDnsNamespace",
        "servicediscovery:CreateService",
        "servicediscovery:DeleteService"
      ]
    )
    resources = [
      "arn:aws:servicediscovery:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:*/*"
    ]
    effect = "Allow"
  }

  statement {
    actions = concat(
      [
        "servicediscovery:ListNamespaces",
        "route53:CreateHostedZone"
      ]
    )
    resources = ["*"]
    effect    = "Allow"
  }
}

output "policy_document" {
  value = data.aws_iam_policy_document.this.json
}
