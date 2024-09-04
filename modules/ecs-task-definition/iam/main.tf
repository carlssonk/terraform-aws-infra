variable "task_definition_arn_query" {
  description = "Data that makes up the query of resource ARN"
}

data "aws_iam_policy_document" "this" {
  statement {
    actions = concat(
      [
        "ecs:*TaskDefinition*",
        "ecs:Get*",
        "ecs:List*",
        "ecs:Describe*"
      ]
    )
    resources = [
      "arn:aws:ecs:${var.task_definition_arn_query}",
      "arn:aws:ecs:${var.task_definition_arn_query}:*"
    ]
    effect = "Allow"
  }
}

output "policy_document" {
  value = data.aws_iam_policy_document.this.json
}
