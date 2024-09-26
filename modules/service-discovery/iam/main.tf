module "globals" {
  source = "../../../globals"
}

data "aws_iam_policy_document" "this" {
  statement {
    actions = concat(
      [
        "servicediscovery:DeleteNamespace",
        "servicediscovery:GetNamespace",
        "servicediscovery:UpdatePrivateDnsNamespace",
        "servicediscovery:CreatePrivateDnsNamespace"
      ]
    )
    resources = [
      "arn:aws:servicediscovery:${module.globals.var.aws_region}:${module.globals.var.aws_account_id}:*/*"
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
