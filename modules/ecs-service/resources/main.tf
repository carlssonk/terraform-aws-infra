

locals {
  fargate_spot_weight     = var.fargate_spot_percentage
  fargate_ondemand_weight = 100 - var.fargate_spot_percentage
}

resource "aws_service_discovery_service" "this" {
  count = var.reverse_proxy_type == "nginx" ? 1 : 0
  name  = var.discovery_name

  dns_config {
    namespace_id = var.service_discovery_namespace_id

    dns_records {
      type = "A"
      ttl  = 60
    }
  }

  force_destroy = true
}

resource "aws_ecs_service" "this" {
  name            = "service-${var.app_name}"
  cluster         = var.cluster_id
  task_definition = var.task_definition_arn
  desired_count   = 1

  network_configuration {
    subnets          = var.subnet_ids
    security_groups  = [var.security_group_id]
    assign_public_ip = var.assign_public_ip
  }

  dynamic "capacity_provider_strategy" {
    for_each = toset(["FARGATE_SPOT", "FARGATE"])
    content {
      capacity_provider = capacity_provider_strategy.value
      weight            = capacity_provider_strategy.value == "FARGATE_SPOT" ? local.fargate_spot_weight : local.fargate_ondemand_weight
    }
  }

  dynamic "load_balancer" {
    for_each = var.reverse_proxy_type == "alb" ? [1] : []
    content {
      target_group_arn = var.alb_target_group_arn
      container_name   = var.container_name
      container_port   = var.container_port
    }
  }

  dynamic "service_registries" {
    for_each = var.reverse_proxy_type == "nginx" ? [1] : [0]
    content {
      registry_arn = aws_service_discovery_service.this[0].arn
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
