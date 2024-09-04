variable "execution_role_arn" {
  description = "ARN of da execution role"
}

variable "task_name" {
  description = "Name of ECS Task Definition"
}

variable "cpu" {
  description = "CPU limit"
}

variable "memory" {
  description = "Memory limit"
}

variable "container_definitions" {
  description = "Define Docker container"
}

resource "aws_ecs_task_definition" "this" {
  family                   = var.task_name
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.cpu
  memory                   = var.memory
  execution_role_arn       = var.execution_role_arn

  container_definitions = var.container_definitions
}

output "task_definition_arn" {
  value = aws_ecs_task_definition.this.arn
}
