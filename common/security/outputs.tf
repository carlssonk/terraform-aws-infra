output "policy_documents" {
  value = [
    module.security_group_alb.policy_document,
    module.security_group_ecs_tasks.policy_document,
    module.security_group_vpc_endpoints.policy_document,
    module.security_group_alb_rules.policy_document,
    module.security_group_ecs_tasks_rules.policy_document,
    module.security_group_vpc_endpoints_rules.policy_document,
    module.vpc_endpoints_gateway.policy_document
  ]
}

output "security_group_alb_id" {
  value = module.security_group_alb.id
}

output "security_group_ecs_tasks_id" {
  value = module.security_group_ecs_tasks.id
}
