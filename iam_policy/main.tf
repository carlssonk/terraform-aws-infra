variable "workflow_step" {}

variable "name" {
  description = "Policy name"
  type        = string
}

variable "policy_documents" {
  description = "List of policy documents"
  type        = list(string)
}

module "globals" {
  source = "../globals"
}

resource "null_resource" "policy_check" {
  triggers = {
    policy_name = "terraform-${var.name}-policy"
  }

  provisioner "local-exec" {
    command = <<EOT
      if aws iam get-policy --policy-arn arn:aws:iam::${module.globals.var.AWS_ACCOUNT_ID}:policy/${"terraform-${var.name}-policy"} >/dev/null 2>&1; then
        echo "true" > ${path.module}/policy_exists.txt
      else
        echo "false" > ${path.module}/policy_exists.txt
      fi
    EOT
  }
}
data "local_file" "policy_exists" {
  filename   = "${path.module}/policy_exists.txt"
  depends_on = [null_resource.policy_check]
}

data "aws_iam_policy" "previous" {
  count = tobool(trimspace(data.local_file.policy_exists.content)) ? 1 : 0
  name  = "terraform-${var.name}-policy"
}

locals {
  previous_policy_document = tobool(module.globals.var.cleanup_policies) ? [] : try([data.aws_iam_policy.previous[0].policy], [])
  policies                 = distinct(concat(local.previous_policy_document, var.policy_documents))

  // Below logic groups all resources together that have the same permissions

  // Maps out the statement for each policy
  merged_statements = flatten([
    for policy in local.policies :
    try(jsondecode(policy).Statement, [])
  ])

  // Groups all identical keys (effect + actions), statement... tells Terraform to create a list of values  when multiple items have the same key
  grouped_statements = {
    for statement in local.merged_statements :
    "${lower(statement.Effect)}-${jsonencode(sort([for action in tolist(statement.Action) : lower(action)]))}" => statement...
  }

  // Loops over each group and collects all resources
  combined_statements = [
    for key, statements in local.grouped_statements : {
      Effect   = statements[0].Effect
      Action   = statements[0].Action
      Resource = distinct(flatten([for s in statements : s.Resource]))
    }
  ]

  current_policy_document = {
    Version   = "2012-10-17"
    Statement = local.combined_statements
  }
}

resource "aws_iam_policy" "policy" {
  count  = var.workflow_step == "iam" ? 1 : 0
  name   = "terraform-${var.name}-policy"
  policy = jsonencode(local.current_policy_document)
}

resource "aws_iam_role_policy_attachment" "attachment" {
  count      = var.workflow_step == "iam" ? 1 : 0
  role       = "terraform-execution-role"
  policy_arn = aws_iam_policy.policy[0].arn
}
