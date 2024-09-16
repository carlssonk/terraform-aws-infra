output "service_name" {
  value = module.aws_ecs_service.this.name
}

output "repo_name" {
  value = module.aws_ecr_repository.this.name
}
