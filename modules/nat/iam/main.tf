data "aws_caller_identity" "current" {}

data "aws_iam_policy_document" "this" {
  statement {
    actions = [
      "iam:CreateRole",
      "iam:DeleteRole",
      "iam:TagRole",
      "iam:PutRolePolicy",
      "iam:PassRole",
      "iam:Get*",
      "iam:List*"
    ]
    resources = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/fck-nat-*"]
    effect    = "Allow"
  }

  statement {
    actions = [
      "iam:*InstanceProfile"
    ]
    resources = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:instance-profile/fck-nat-*"]
    effect    = "Allow"
  }
  # dynamic "statement" {
  #   for_each = var.nat_type == "fck-nat" ? ["x"] : []
  #   content {
  #     actions = [
  #       "iam:CreateRole",
  #       "iam:DeleteRole",
  #     ]
  #     resources = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/fck-nat-*"]
  #     effect    = "Allow"
  #   }
  # }
}
