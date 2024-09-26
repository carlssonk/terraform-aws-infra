output "policy_documents" {
  value = [
    try(module.service_discovery_namespace[0].policy_document, null),
    try(module.ec2_instance_nginx_proxy[0].policy_document, null),
    try(module.ec2_instance_nginx_eip[0].policy_document, null),
    try(module.main_alb[0].policy_document, null),
    try(module.main_alb_access_logs_bucket[0].policy_document, null),
    module.main_ecs_cluster.policy_document
  ]
}

output "main_alb_dns_name" {
  value = try(module.main_alb[0].dns_name, null)
}

output "main_alb_listener_arn" {
  value = try(module.main_alb[0].listener_arn, null)
}

output "service_discovery_namespace_arn" {
  value = try(module.service_discovery_namespace[0].arn, null)
}

output "main_ecs_cluster_name" {
  value = module.main_ecs_cluster.name
}

output "main_ecs_cluster_id" {
  value = module.main_ecs_cluster.id
}

output "nginx_proxy_public_ip" {
  value = try(module.ec2_instance_nginx_eip[0].public_ip, null)
}
