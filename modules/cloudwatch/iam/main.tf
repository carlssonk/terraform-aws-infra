data "aws_iam_policy_document" "this" {
  statement {
    actions = concat(
      [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:DeleteLogGroup",
        "logs:DeleteLogStream",
        "logs:Put*",
        "logs:List*",
        "logs:Get*",
        "logs:Describe*",
      ],
    )
    resources = ["*"]
    effect    = "Allow"
  }
}
