output "policy_documents" {
  value = [
    module.bucket.policy_document
  ]
}
