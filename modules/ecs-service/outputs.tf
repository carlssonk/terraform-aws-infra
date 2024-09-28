output "service_name" {
  value = aws_ecs_service.this.name
}

output "repo_name" {
  value = aws_ecr_repository.this.name
}
