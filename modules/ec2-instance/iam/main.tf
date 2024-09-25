
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
    resources = ["arn:aws:ec2:eu-north-1:752502408032:instance/*"]
    effect    = "Allow"
  }
}
