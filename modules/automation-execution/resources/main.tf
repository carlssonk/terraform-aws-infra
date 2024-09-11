variable "cluster_name" {
  description = "Name of ECS Cluster"
}

variable "service_name" {
  description = "Name of ECS Service"
}

variable "task_definition_arn" {
  description = "ARN of ECS Task Definition"
}

variable "aws_account_id" {
  description = "AWS Account ID"
}

variable "document_name" {
  description = "Name of AWS SSM Document"
}

resource "aws_ssm_document" "troubleshoot_ecs" {
  name            = var.document_name
  document_type   = "Automation"
  document_format = "YAML"

  content = <<DOC
schemaVersion: '0.3'
description: 'Troubleshoot ECS Task Failed to Start'
assumeRole: 'arn:aws:iam::${var.aws_account_id}:role/terraform-execution-role'
mainSteps:
  - name: StartAutomation
    action: 'aws:executeAutomation'
    inputs:
      DocumentName: AWSSupport-TroubleshootECSTaskFailedToStart
      RuntimeParameters:
        ClusterName: '${var.cluster_name}'
        ServiceName: '${var.service_name}'
        TaskDefinition: '${var.task_definition_arn}'
        ExecutionRoleArn: 'arn:aws:iam::${var.aws_account_id}:role/ecsTaskExecutionRole'
DOC

  lifecycle {
    create_before_destroy = true
  }
}
