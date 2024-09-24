output "policy_document" {
  value = jsonencode(local.policy_document_result)
}

output "name" {
  value = var.name
}
