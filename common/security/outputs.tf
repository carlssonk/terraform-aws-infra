output "policy_documents" {
  value = [
    for mod in values(module) :
    mod.policy_document
    if can(mod.policy_document)
  ]
}

output "security_group_alb_id" {
  value = module.security_group_alb.id
}

output "security_group_ecs_tasks_id" {
  value = module.security_group_ecs_tasks.id
}
