data "aws_iam_policy_document" "this" {
  statement {
    actions = concat(
      [
        "ec2:DescribeSecurityGroups",
        "ec2:DescribeSecurityGroupRules",
        "ec2:DescribeVpcs",
        "ec2:DescribePrefixLists"
      ]
    )
    resources = ["*"]
    effect    = "Allow"
  }

  statement {
    actions = concat(
      [
        "ec2:AuthorizeSecurityGroupIngress",
        "ec2:AuthorizeSecurityGroupEgress",
        "ec2:RevokeSecurityGroupIngress",
        "ec2:RevokeSecurityGroupEgress",
        "ec2:UpdateSecurityGroupRuleDescriptionsIngress",
        "ec2:UpdateSecurityGroupRuleDescriptionsEgress",
        "ec2:ModifySecurityGroupRules"
      ]
    )
    resources = [
      "arn:aws:ec2:*:*:security-group/*",
      "arn:aws:ec2:*:*:security-group-rule/*"
    ]
    effect = "Allow"
  }
}

output "policy_document" {
  value = data.aws_iam_policy_document.this.json
}
