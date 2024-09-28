module "globals" {
  source = "../../globals"
}
data "aws_region" "current" {}
data "aws_caller_identity" "current" {}

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
      "arn:aws:ecs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:service/MainCluster/service-${var.app_name}",
      "arn:aws:ecs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:service/MainCluster/service-${var.app_name}/*"
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
      "arn:aws:ecr:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:repository/repo-${var.app_name}",
      "arn:aws:ecr:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:repository/repo-${var.app_name}/*"
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
      "arn:aws:servicediscovery:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:*/*"
    ]
    effect = "Allow"
  }
}

output "policy_document" {
  value = data.aws_iam_policy_document.this.json
}
