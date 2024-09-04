variable "service_name" {
  description = "Name of service"
  type        = string
}

variable "subnet_ids" {
  description = "List of subnet ID's to use"
  type        = list(string)
}

variable "cluster_id" {
  description = "Cluster ID to use"
  type        = string
}

variable "task_definition_arn" {
  description = "Task definition to use"
  type        = string
}

variable "security_group_id" {
  description = "ID of a security group"
  type        = string
}
