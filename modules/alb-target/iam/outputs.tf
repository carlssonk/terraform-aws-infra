# Outputs from iam
output "policy_document" {
  value = data.aws_iam_policy_document.this.json
}

# Outputs from resources
output "arn" {
  value = null
}


