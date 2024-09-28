data "aws_caller_identity" "current" {}

data "aws_iam_policy_document" "this" {
  statement {
    actions = concat(
      [
        "acm:*Certificate"
      ]
    )
    resources = [
      "arn:aws:acm:eu-north-1:${data.aws_caller_identity.current.account_id}:certificate/*"
    ]
    effect = "Allow"
  }
}

output "policy_document" {
  value = data.aws_iam_policy_document.this.json
}
