output "policy_documents" {
  value = [
    module.main_alb.policy_document,
    module.main_ecs_cluster.policy_document
  ]
}

output "main_alb_dns_name" {
  value = module.main_alb.dns_name
}

output "main_alb_listener_arn" {
  value = module.main_alb.listener_arn
}

output "main_ecs_cluster_name" {
  value = module.main_ecs_cluster.name
}

output "main_ecs_cluster_id" {
  value = module.main_ecs_cluster.id
}
