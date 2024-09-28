data "aws_caller_identity" "current" {}

data "aws_iam_policy_document" "this" {
  statement {
    actions = [
      "iam:CreateRole",
      "iam:DeleteRole",
      "iam:TagRole",
      "iam:PutRolePolicy",
      "iam:GetRole"
    ]
    resources = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/main-fck-nat-*"]
    effect    = "Allow"
  }
  # dynamic "statement" {
  #   for_each = var.nat_type == "fck-nat" ? ["x"] : []
  #   content {
  #     actions = [
  #       "iam:CreateRole",
  #       "iam:DeleteRole",
  #     ]
  #     resources = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/main-fck-nat-*"]
  #     effect    = "Allow"
  #   }
  # }
}
