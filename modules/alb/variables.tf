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

variable "domains_for_certificates" {
  description = "Root domain names used for creating ACM Certificates"
  type        = list(string)
}

variable "access_logs_bucket_name" {
  description = "s3 bucket name for alb access logs"
  type        = string
  default     = ""
}

variable "access_logs_enabled" {
  description = "Toggle access logs"
  type        = bool
  default     = false
}
