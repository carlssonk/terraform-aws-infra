variable "aws_account_id" {
  description = "AWS Account ID"
}

data "aws_iam_policy_document" "this" {
  statement {
    actions = concat(
      [
        "ssm:CreateDocument"
      ]
    )
    resources = ["arn:aws:ssm:eu-north-1:${var.aws_account_id}:document/TroubleshootECSTaskFailedToStart"]
    effect    = "Allow"
  }
}

output "policy_document" {
  value = data.aws_iam_policy_document.this.json
}
