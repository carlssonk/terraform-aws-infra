data "aws_iam_policy_document" "this" {
  statement {
    actions = concat(
      [
        "ec2:CreateSecurityGroup",
        "ec2:DeleteSecurityGroup",
        "ec2:Describe*"
      ]
    )
    resources = ["*"]
    effect    = "Allow"
  }
}

output "policy_document" {
  value = data.aws_iam_policy_document.this.json
}
