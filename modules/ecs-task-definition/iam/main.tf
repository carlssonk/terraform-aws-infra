variable "task_name" {
  description = "Name of ECS Task Definition"
}

module "globals" {
  source = "../globals"
}

locals {
  task_definition_arn_data = "${module.globals.var.region}:${module.globals.var.AWS_ACCOUNT_ID}:task-definition/${var.task_name}"
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
      "arn:aws:ecs:${local.task_definition_arn_data}",
      "arn:aws:ecs:${local.task_definition_arn_data}:*"
    ]
    effect = "Allow"
  }
}

output "policy_document" {
  value = data.aws_iam_policy_document.this.json
}
