output "policy_document" {
  value = module.iam_policy.policy_document
}

output "apps" {
  value = local.apps
}
