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

resource "random_id" "document_suffix" {
  byte_length = 8
}

resource "aws_ssm_document" "troubleshoot_ecs" {
  name            = "TroubleshootECSTaskFailedToStart-${random_id.document_suffix.hex}"
  document_type   = "Automation"
  document_format = "YAML"
  version_name    = "latest"

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
mainSteps:
  - name: StartAutomation
    action: 'aws:executeAutomation'
    inputs:
      DocumentName: AWSSupport-TroubleshootECSTaskFailedToStart
      RuntimeParameters:
        ClusterName: '{{ClusterName}}'
        ServiceName: '{{ServiceName}}'
        TaskDefinition: '{{TaskDefinition}}'
        ExecutionRoleArn: '{{ExecutionRoleArn}}'
DOC

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_ssm_association" "troubleshoot_ecs" {
  name = aws_ssm_document.troubleshoot_ecs.name

  parameters = {
    ClusterName      = var.cluster_name
    ServiceName      = var.service_name
    TaskDefinition   = var.task_definition
    ExecutionRoleArn = "arn:aws:iam::${var.aws_account_id}:role/ecsTaskExecutionRole"
  }

  targets {
    key    = "InstanceIds"
    values = ["*"]
  }
}
