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
        "ec2:ModifyNetworkInterfaceAttribute",
        "ec2:StopInstances",
        "ec2:ModifyInstanceAttribute",
        "ec2:TerminateInstances",
        "ec2:StartInstances",
        "ec2:RebootInstances"
      ]
    )
    resources = ["*"]
    effect    = "Allow"
  }
}
