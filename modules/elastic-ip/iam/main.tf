
data "aws_iam_policy_document" "this" {
  statement {
    actions = concat(
      [
        "ec2:AllocateAddress",
        "ec2:AssociateAddress",
        "ec2:DescribeAddresses",
        "ec2:DescribeInstances",
        "ec2:DisassociateAddress",
        "ec2:ReleaseAddress"
      ]
    )
    resources = ["*"]
    effect    = "Allow"
  }
}
