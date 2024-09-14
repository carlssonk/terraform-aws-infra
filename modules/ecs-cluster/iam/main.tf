module "globals" {
  source = "../../../globals"
}

data "aws_iam_policy_document" "this" {
  statement {
    actions = concat(
      [
        "ecs:CreateCluster",
        "ecs:DeleteCluster",
        "ecs:Get*",
        "ecs:List*",
        "ecs:Describe*"
      ]
    )
    resources = [
      "arn:aws:ecs:${module.globals.var.region}:${module.globals.var.AWS_ACCOUNT_ID}:cluster/${var.cluster_name}",
      "arn:aws:ecs:${module.globals.var.region}:${module.globals.var.AWS_ACCOUNT_ID}:cluster/${var.cluster_name}/*"
    ]
    effect = "Allow"
  }
}
