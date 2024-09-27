output "policy_documents" {
  value = {
    (module.networking_policy.name)       = module.networking_policy.policy_document
    (module.security_policy.name)         = module.security_policy.policy_document
    (module.services_policy.name)         = module.services_policy.policy_document
    (module.s3_websites_policy.name)      = module.s3_websites_policy.policy_document
    (module.fargate_services_policy.name) = module.fargate_services_policy.policy_document
  }
}
