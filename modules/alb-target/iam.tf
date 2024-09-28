data "aws_region" "current" {}
data "aws_caller_identity" "current" {}

data "aws_iam_policy_document" "this" {
  statement {
    actions = concat(
      [
        "elasticloadbalancing:*Rule*",
        "elasticloadbalancing:*Target*",
      ],
    )
    resources = [
      "arn:aws:elasticloadbalancing:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:listener-rule/app/*",
      "arn:aws:elasticloadbalancing:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:targetgroup/*"
    ]
    effect = "Allow"
  }
}

output "policy_document" {
  value = try(data.aws_iam_policy_document.this.json, null)
}
