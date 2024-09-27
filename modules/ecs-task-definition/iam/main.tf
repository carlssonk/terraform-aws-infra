data "aws_region" "current" {}
data "aws_caller_identity" "current" {}

data "aws_iam_policy_document" "this" {
  statement {
    actions = concat(
      [
        "ecs:*TaskDefinition*",
        "ecs:Get*",
        "ecs:List*",
        "ecs:Describe*",
        "ecs:TagResource"
      ]
    )
    resources = [
      "arn:aws:ecs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:task-definition/task-${var.app_name}",
      "arn:aws:ecs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:task-definition/task-${var.app_name}:*"
    ]
    effect = "Allow"
  }

  statement {
    actions = concat(
      [
        "iam:PassRole"
      ]
    )
    resources = [
      "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/ecsTaskExecutionRole"
    ]
    effect = "Allow"
  }

  statement {
    actions = concat(
      [
        "ecs:Describe*",
        "ecs:DeregisterTaskDefinition"
      ]
    )
    resources = [
      "*"
    ]
    effect = "Allow"
  }
}
