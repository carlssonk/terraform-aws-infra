data "aws_region" "current" {}
data "aws_caller_identity" "current" {}

data "aws_iam_policy_document" "this" {

  statement {
    actions = [
      "iam:CreateRole",
      "iam:DeleteRole",
      "iam:TagRole",
      "iam:PutRolePolicy",
      "iam:DeleteRolePolicy",
      "iam:PassRole",
      "iam:Get*",
      "iam:List*"
    ]
    resources = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/the-fck-nat-*"]
    effect    = "Allow"
  }

  statement {
    actions = [
      "iam:*InstanceProfile"
    ]
    resources = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:instance-profile/the-fck-nat-*"]
    effect    = "Allow"
  }

  statement {
    actions = [
      "ec2:*LaunchTemplate*"
    ]
    resources = ["arn:aws:ec2:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:launch-template/*"]
    effect    = "Allow"
  }

}

output "policy_document" {
  value = try(data.aws_iam_policy_document.this.json, null)
}
