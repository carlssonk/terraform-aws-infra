variable "service_name" {
  description = "Name of the service"
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
      "arn:aws:ecs:::${var.service_name}",
      "arn:aws:ecs:::${var.service_name}/*"
    ]
    effect = "Allow"
  }
}

output "policy_document" {
  value = data.aws_iam_policy_document.this.json
}