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
      "arn:aws:ecs:${module.globals.var.aws_region}:${module.globals.var.aws_account_id}:task-definition/task-${var.app_name}",
      "arn:aws:ecs:${module.globals.var.aws_region}:${module.globals.var.aws_account_id}:task-definition/task-${var.app_name}:*"
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
      "arn:aws:iam::${module.globals.var.aws_account_id}:role/ecsTaskExecutionRole"
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
