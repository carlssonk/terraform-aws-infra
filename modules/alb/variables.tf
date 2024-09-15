variable "name" {
  description = "Name of Application Load Balancer"
  type        = string
}

variable "vpc_id" {
  description = "ID of VPC"
  type        = string
}

variable "subnet_ids" {
  description = "List of subnet IDS"
  type        = list(string)
}

variable "security_group_id" {
  description = "ID of Security Group"
  type        = string
}

variable "root_domain_names" {
  description = "Root domain names used for creating ACM Certificates"
  type        = list(string)
}
