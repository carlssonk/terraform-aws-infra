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
      "arn:aws:ecs:${module.globals.var.aws_region}:${module.globals.var.aws_account_id}:service/MainCluster/service-${var.app_name}",
      "arn:aws:ecs:${module.globals.var.aws_region}:${module.globals.var.aws_account_id}:service/MainCluster/service-${var.app_name}/*"
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
      "arn:aws:ecr:${module.globals.var.aws_region}:${module.globals.var.aws_account_id}:repository/repo-${var.app_name}",
      "arn:aws:ecr:${module.globals.var.aws_region}:${module.globals.var.aws_account_id}:repository/repo-${var.app_name}/*"
    ]
    effect = "Allow"
  }

  statement {
    actions = concat(
      [
        "servicediscovery:CreateHttpNamespace",
        "servicediscovery:Get*",
        "servicediscovery:List*",
        "servicediscovery:Describe*"
      ]
    )
    resources = [
      "arn:aws:servicediscovery:${module.globals.var.aws_region}:${module.globals.var.aws_account_id}:*/*"
    ]
    effect = "Allow"
  }
}
