module "globals" {
  source = "../../../globals"
}

data "aws_iam_policy_document" "this" {
  statement {
    actions = concat(
      [
        "ecs:CreateService",
        "ecs:DeleteService",
        "ecs:UpdateService",
        "ecs:Get*",
        "ecs:List*",
        "ecs:Describe*"
      ]
    )
    resources = [
      "arn:aws:ecs:${module.globals.var.REGION}:${module.globals.var.AWS_ACCOUNT_ID}:service/MainCluster/service-${var.app_name}",
      "arn:aws:ecs:${module.globals.var.REGION}:${module.globals.var.AWS_ACCOUNT_ID}:service/MainCluster/service-${var.app_name}/*"
    ]
    effect = "Allow"
  }

  statement {
    actions = concat(
      [
        "ecr:CreateRepository",
        "ecr:DeleteRepository",
        "ecr:Get*",
        "ecr:List*",
        "ecr:Describe*"
      ]
    )
    resources = [
      "arn:aws:ecr:${module.globals.var.REGION}:${module.globals.var.AWS_ACCOUNT_ID}:repository/repo-${var.app_name}",
      "arn:aws:ecr:${module.globals.var.REGION}:${module.globals.var.AWS_ACCOUNT_ID}:repository/rep-${var.app_name}/*"
    ]
    effect = "Allow"
  }
}
