module "globals" {
  source = "../../../globals"
}

resource "aws_ecs_task_definition" "this" {
  family                   = "task-${var.app_name}"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.cpu
  memory                   = var.memory
  execution_role_arn       = "arn:aws:iam::${module.globals.var.AWS_ACCOUNT_ID}:role/ecsTaskExecutionRole"

  container_definitions = var.container_definitions
}
