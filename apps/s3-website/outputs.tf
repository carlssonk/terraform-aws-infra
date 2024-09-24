output "policy_document" {
  value = module.iam_policy.policy_document
}

output "policy_documents" {
  value = [
    module.subdomain_bucket.policy_document,
    try(module.root_bucket.policy_document, null)
  ]
}
