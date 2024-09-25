output "policy_documents" {
  value = {
    (module.common_policy.name)               = module.common_policy.policy_document
    (module.s3_websites_policy.name)          = module.s3_websites_policy.policy_document
    (module.fargate_services_alb_policy.name) = module.fargate_services_alb_policy.policy_document
  }
}
