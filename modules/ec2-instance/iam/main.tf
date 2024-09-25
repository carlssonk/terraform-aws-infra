module "globals" {
  source = "../../../globals"
}

data "aws_iam_policy_document" "this" {
  statement {
    actions = concat(
      [
        "ec2:DescribeInstances",
        "ec2:DescribeTags",
        "ec2:DescribeVolumes",
        "ec2:AttachVolume",
        "ec2:DetachVolume"
      ]
    )
    resources = ["*"]
    effect    = "Allow"
  }

  statement {
    actions = concat(
      [
        "ec2:RunInstances"
      ]
    )
    resources = [
      "arn:aws:ec2:${module.globals.var.aws_region}:${module.globals.var.aws_account_id}:instance/*",
      "arn:aws:ec2:${module.globals.var.aws_region}:${module.globals.var.aws_account_id}:network-interface/*"
    ]
    effect = "Allow"
  }
}
