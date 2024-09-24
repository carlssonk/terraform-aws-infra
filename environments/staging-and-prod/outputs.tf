output "policy_documents" {
  value = {
    (module.common_policy.name)      = module.common_policy.policy_document
    (module.s3_websites_policy.name) = module.s3_websites_policy.policy_document
    (module.blackjack_policy.name)   = module.blackjack_policy.policy_document
    (module.flagracer_policy.name)   = module.flagracer_policy.policy_document
  }
}
