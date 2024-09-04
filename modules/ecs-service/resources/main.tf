variable "service_name" {
  description = "Name of service"
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

resource "aws_ecs_service" "main" {
  name            = var.service_name
  cluster         = var.cluster_id
  task_definition = var.task_definition_arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = var.subnet_ids
    assign_public_ip = false
    security_groups  = [var.security_group_id]
  }
}
