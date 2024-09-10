variable "service_name" {
  description = "Name of ECS service"
}

variable "repo_name" {
  description = "Name of ECR repository"
}

variable "subnet_ids" {
  description = "List of subnet ID's to use"
}

variable "cluster_id" {
  description = "Cluster ID to use"
}

variable "task_definition_arn" {
  description = "Task definition to use"
}

variable "security_group_id" {
  description = "ID of a security group"
}

variable "alb_target_group_arn" {
  description = "ARN for ALB Target Group"
}

variable "container_name" {
  description = "Docker container name"
}

variable "container_port" {
  description = "Docker container port"
}

resource "aws_ecs_service" "main" {
  name                              = var.service_name
  cluster                           = var.cluster_id
  task_definition                   = var.task_definition_arn
  desired_count                     = 1
  launch_type                       = "FARGATE"
  health_check_grace_period_seconds = 120

  network_configuration {
    subnets          = var.subnet_ids
    assign_public_ip = true
    security_groups  = [var.security_group_id]
  }

  load_balancer {
    target_group_arn = var.alb_target_group_arn
    container_name   = var.container_name
    container_port   = var.container_port
  }

  force_delete = true
}

// Create one ECR repo per service
resource "aws_ecr_repository" "app_repo" {
  name                 = var.repo_name
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  encryption_configuration {
    encryption_type = "AES256"
  }

  force_delete = true
}
