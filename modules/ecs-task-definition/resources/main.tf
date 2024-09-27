data "aws_caller_identity" "current" {}

resource "aws_ecs_task_definition" "this" {
  family                   = "task-${var.app_name}"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.cpu
  memory                   = var.memory
  execution_role_arn       = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/ecsTaskExecutionRole"

  container_definitions = var.container_definitions

  tags = {
    Name = "task-${var.app_name}"
  }
}
