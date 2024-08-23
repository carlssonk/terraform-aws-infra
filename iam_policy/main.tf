variable "name" {
  description = "Policy name"
  type        = string
}

variable "policy_documents" {
  description = "List of policy documents"
  type        = list(string)
}

variable "transition_period" {
  description = "Number of days to keep the old policy"
  type        = number
  default     = 30
}

module "globals" {
  source = "../globals"
}

resource "time_rotating" "policy_rotation" {
  rotation_days = var.transition_period
}

# data "terraform_remote_state" "previous" {
#   backend = "s3"
#   config = {
#     bucket = "${module.globals.var.organization}-terraform-state-bucket-${terraform.workspace}"
#     key    = "iam/terraform.tfstate"
#     region = module.globals.var.region
#   }
# }

locals {


  # workflow_step       = module.globals.var.workflow_step
  # transition_complete = timeadd(time_rotating.policy_rotation.id, "${var.transition_period * 24}h") < timestamp()

  # previous_policies = try(data.terraform_remote_state.previous.outputs.current_policies, [])

  # current_policies = distinct(concat(local.previous_policies, var.policy_documents))

  # transition_policy = {
  #   Version = "2012-10-17"
  #   Statement = flatten([
  #     for doc in local.current_policies : try(jsondecode(doc).Statement, null)
  #   ])
  # }

  # final_policy = {
  #   Version = "2012-10-17"
  #   Statement = flatten([
  #     for doc in var.policy_documents : try(jsondecode(doc).Statement, null)
  #   ])
  # }

  merged_statements = flatten([
    for policy in var.policy_documents :
    try(jsondecode(policy).Statement, [])
  ])

  grouped_statements = {
    for statement in local.merged_statements :
    "${lower(statement.Effect)}-${jsonencode(sort([for action in tolist(statement.Action) : lower(action)]))}" => statement...
  }

  combined_statements = [
    for key, statements in local.grouped_statements : {
      Effect   = statements[0].Effect
      Action   = statements[0].Action
      Resource = distinct(flatten([for s in statements : s.Resource]))
    }
  ]

  combined_policy = {
    Version   = "2012-10-17"
    Statement = combined_statements
  }

  # combined_policy = local.transition_complete ? local.final_policy : local.transition_policy
}

resource "aws_iam_policy" "policy" {
  count  = module.globals.run_iam
  name   = "terraform-${var.name}-policy"
  policy = jsonencode(local.combined_policy)
}

resource "aws_iam_role_policy_attachment" "attachment" {
  count      = module.globals.run_iam
  role       = "terraform-execution-role"
  policy_arn = aws_iam_policy.policy[0].arn
}

# output "current_policies" {
#   value       = local.current_policies
#   description = "The current set of policies, including both old and new"
# }
