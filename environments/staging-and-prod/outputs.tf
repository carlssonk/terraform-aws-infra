output "policy_documents" {
  value = merge(
    {
      (module.networking_policy.name) = module.networking_policy.policy_document
      (module.security_policy.name)   = module.security_policy.policy_document
      (module.services_policy.name)   = module.services_policy.policy_document
    },
    length(module.s3_websites_policy) > 0 ? {
      (module.s3_websites_policy[0].name) = module.s3_websites_policy[0].policy_document
    } : {},
    length(module.s3_media_policy) > 0 ? {
      (module.s3_media_policy[0].name) = module.s3_media_policy[0].policy_document
    } : {},
    length(module.fargate_services_policy) > 0 ? {
      (module.fargate_services_policy[0].name) = module.fargate_services_policy[0].policy_document
    } : {}
  )
}
