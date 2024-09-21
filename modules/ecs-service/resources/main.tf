resource "aws_service_discovery_http_namespace" "this" {
  name = var.app_name
}

resource "aws_ecs_service" "this" {
  name            = "service-${var.app_name}"
  cluster         = var.cluster_id
  task_definition = var.task_definition_arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = var.subnet_ids
    security_groups  = [var.security_group_id]
    assign_public_ip = var.assign_public_ip
  }

  load_balancer {
    target_group_arn = var.alb_target_group_arn
    container_name   = var.container_name
    container_port   = var.container_port
  }

  service_connect_configuration {
    enabled   = true
    namespace = aws_service_discovery_http_namespace.this.arn
    service {
      port_name      = "http"
      discovery_name = "app"
      client_alias {
        port     = 80
        dns_name = "app.local"
      }
    }
  }

  force_delete = true
}

// Create one ECR repo per service
resource "aws_ecr_repository" "this" {
  name                 = "repo-${var.app_name}"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  encryption_configuration {
    encryption_type = "AES256"
  }

  force_delete = true
}
