variable "cluster_name" {
  description = "Name of ECS Cluster"
}

variable "service_name" {
  description = "Name of ECS Service"
}

variable "task_definition" {
  description = "Name of ECS Task Definition"
}

variable "aws_account_id" {
  description = "AWS Account ID"
}

module "globals" {
  source = "../../../globals"
}

resource "aws_ssm_automation_execution" "troubleshoot_ecs" {
  document_name    = "AWSSupport-TroubleshootECSTaskFailedToStart"
  document_version = "$LATEST"

  parameters = {
    ClusterName      = var.cluster_name
    ServiceName      = var.service_name
    TaskDefinition   = var.task_definition
    ExecutionRoleArn = "arn:aws:iam::${var.aws_account_id}:role/ecsTaskExecutionRole"
  }
}

output "automation_execution_id" {
  value = aws_ssm_automation_execution.troubleshoot_ecs.automation_execution_id
}
