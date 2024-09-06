variable "service_name" {
  description = "Name of the service"
}

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
      "arn:aws:ecs:${module.globals.var.region}:${module.globals.var.AWS_ACCOUNT_ID}:service/SimpleCluster/${var.service_name}",
      "arn:aws:ecs:${module.globals.var.region}:${module.globals.var.AWS_ACCOUNT_ID}:service/SimpleCluster/${var.service_name}/*"
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
      "arn:aws:ecr:${module.globals.var.region}:${module.globals.var.AWS_ACCOUNT_ID}:repository/${var.service_name}",
      "arn:aws:ecr:${module.globals.var.region}:${module.globals.var.AWS_ACCOUNT_ID}:repository/${var.service_name}/*"
    ]
    effect = "Allow"
  }
}

output "policy_document" {
  value = data.aws_iam_policy_document.this.json
}
