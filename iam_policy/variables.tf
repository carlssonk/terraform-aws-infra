variable "workflow_step" {
  description = "iam|resources"
  type        = string
}

variable "name" {
  description = "Policy name"
  type        = string
}

variable "policy_documents" {
  description = "List of policy documents"
  type        = list(string)
}
