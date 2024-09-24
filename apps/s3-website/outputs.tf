output "policy_documents" {
  value = [
    module.subdomain_bucket.policy_document,
    try(module.root_bucket[0].policy_document, null)
  ]
}
