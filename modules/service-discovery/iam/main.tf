data "aws_iam_policy_document" "this" {
  statement {
    actions = concat(
      [
        "servicediscovery:CreateHttpNamespace",
        "servicediscovery:DeleteNamespace",
        "servicediscovery:GetNamespace",
        "servicediscovery:UpdateHttpNamespace",
        "servicediscovery:servicediscovery:CreatePrivateDnsNamespace",
        "servicediscovery:servicediscovery:UpdatePrivateDnsNamespace",
      ]
    )
    resources = [
      "arn:aws:servicediscovery:*:*:namespace/*"
    ]
    effect = "Allow"
  }

  statement {
    actions = concat(
      [
        "servicediscovery:ListNamespaces"
      ]
    )
    resources = ["*"]
    effect    = "Allow"
  }
}
