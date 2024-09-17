# Outputs from iam
output "policy_document" {
  value = data.aws_iam_policy_document.this.json
}

# Outputs from resources
output "dns_name" {
  value = null
}

output "listener_arn" {
  value = null
}


