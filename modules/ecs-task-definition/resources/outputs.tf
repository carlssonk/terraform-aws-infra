output "task_definition_arn" {
  value = aws_ecs_task_definition.this.arn
}

output "task_id" {
  value = aws_ecs_task_definition.this.id
}
