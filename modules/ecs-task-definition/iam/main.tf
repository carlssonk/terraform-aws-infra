module "globals" {
  source = "../../../globals"
}

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
      "arn:aws:ecs:${module.globals.var.AWS_REGION}:${module.globals.var.AWS_ACCOUNT_ID}:task-definition/task-${var.app_name}",
      "arn:aws:ecs:${module.globals.var.AWS_REGION}:${module.globals.var.AWS_ACCOUNT_ID}:task-definition/task-${var.app_name}:*"
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
      "arn:aws:iam::${module.globals.var.AWS_ACCOUNT_ID}:role/ecsTaskExecutionRole"
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
