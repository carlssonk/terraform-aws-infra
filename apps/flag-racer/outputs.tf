output "policy_documents" {
  value = [
    module.ecs_task_definition.policy_document,
    module.alb_target_group.policy_document,
    module.ecs_service.policy_document,
    module.cloudwatch.policy_document
  ]
}
