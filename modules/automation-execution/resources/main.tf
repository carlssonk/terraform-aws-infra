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
parameters:
  ClusterName:
    type: String
    description: 'Name of the ECS cluster'
  ServiceName:
    type: String
    description: 'Name of the ECS service'
  TaskDefinition:
    type: String
    description: 'ARN of the task definition'
  ExecutionRoleArn:
    type: String
    description: 'ARN of the ECS task execution role'
  TaskId:
    type: String
    description: 'ID of the ECS task to troubleshoot'
    default: ''
mainSteps:
  - name: StartAutomation
    action: 'aws:executeAutomation'
    inputs:
      DocumentName: AWSSupport-TroubleshootECSTaskFailedToStart
      RuntimeParameters:
        ClusterName: '${var.cluster_name}'
        ServiceName: '${var.service_name}'
        TaskDefinition: '${var.task_definition_arn}'
        TaskId: '{{TaskId}}'
        ExecutionRoleArn: 'arn:aws:iam::${var.aws_account_id}:role/ecsTaskExecutionRole'
DOC

  lifecycle {
    create_before_destroy = true
  }
}
