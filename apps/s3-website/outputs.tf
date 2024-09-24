output "policy_documents" {
  value = [
    module.subdomain_bucket.policy_document,
    try(module.root_bucket.policy_document, null)
  ]
}
