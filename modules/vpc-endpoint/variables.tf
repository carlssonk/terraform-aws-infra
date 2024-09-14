module "globals" {
  source = "../../globals"
}

variable "endpoints" {
  description = "List of service name endpoints"
  type        = list(string)
}

variable "vpc_id" {
  description = "ID of the VPC"
  type        = string
}

variable "subnet_ids" {
  description = "ID of the subnets"
  type        = list(string)
}

variable "security_group_id" {
  description = "ID of the security group"
  type        = string
}
