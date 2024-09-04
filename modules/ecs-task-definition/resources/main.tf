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

module "globals" {
  source = "../globals"
}

resource "aws_ecs_task_definition" "this" {
  family                   = var.task_name
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.cpu
  memory                   = var.memory
  execution_role_arn       = "arn:aws:iam::${module.globals.var.AWS_ACCOUNT_ID}:role/ecsTaskExecutionRole"

  container_definitions = var.container_definitions
}

output "task_definition_arn" {
  value = aws_ecs_task_definition.this.arn
}
