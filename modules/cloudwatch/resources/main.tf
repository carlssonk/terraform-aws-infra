variable "log_group_name" {
  description = "Name of Cloudwatch log group"
}

resource "aws_cloudwatch_log_group" "ecs_logs" {
  name              = "/ecs/${log_group_name}"
  retention_in_days = 30
}

output "log_group_name" {
  value = "/ecs/${log_group_name}"
}
