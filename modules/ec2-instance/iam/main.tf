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
        "ec2:DetachVolume",
        "ec2:RunInstances",
        "ec2:ModifyNetworkInterfaceAttribute"
      ]
    )
    resources = ["*"]
    effect    = "Allow"
  }
}
