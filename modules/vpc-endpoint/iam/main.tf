
data "aws_iam_policy_document" "this" {
  statement {
    actions = concat(
      [
        "ec2:DescribeVpcEndpoints",
        "ec2:DescribeVpcs",
        "ec2:DescribeSubnets",
        "ec2:DescribeSecurityGroups",
        "ec2:DescribePrefixLists"
      ]
    )
    resources = ["*"]
    effect    = "Allow"
  }

  statement {
    actions = concat(
      [
        "ec2:CreateVpcEndpoint",
        "ec2:ModifyVpcEndpoint",
        "ec2:DeleteVpcEndpoints"
      ]
    )
    resources = [
      "arn:aws:ec2:*:*:vpc-endpoint/*",
      "arn:aws:ec2:*:*:vpc/*",
      "arn:aws:ec2:*:*:subnet/*",
      "arn:aws:ec2:*:*:security-group/*"
    ]
    effect = "Allow"
  }
}
