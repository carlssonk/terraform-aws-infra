output "policy_documents" {
  value = [
    module.ecs_task_definition.policy_document,
    try(module.alb_target_group[0].policy_document, null),
    module.ecs_service.policy_document,
    module.cloudwatch.policy_document
  ]
}
