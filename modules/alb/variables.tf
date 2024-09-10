variable "alb_name" {
  description = "Name of Application Load Balancer"
  type        = string
}

variable "vpc_id" {
  description = "ID of VPC"
  type        = string
}

variable "public_subnet_ids" {
  description = "List of public subnet IDS"
  type        = list(string)
}
