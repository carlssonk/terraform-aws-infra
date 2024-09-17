# Outputs from iam
output "policy_document" {
  value = data.aws_iam_policy_document.this.json
}

# Outputs from resources
output "id" {
  value = null
}

output "private_subnet_ids" {
  value = null
}

output "public_subnet_ids" {
  value = null
}

output "private_route_table_ids" {
  value = null
}

output "public_route_table_ids" {
  value = null
}


