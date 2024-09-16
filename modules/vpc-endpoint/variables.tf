variable "endpoints" {
  description = "List of service name endpoints"
  type        = list(string)
}

variable "type" {
  description = "interface|gateway"
  type        = string
}

variable "vpc_id" {
  description = "ID of the VPC"
  type        = string
}

variable "subnet_ids" {
  description = "ID of the subnets"
  type        = list(string)
  default     = []
}

variable "security_group_id" {
  description = "ID of the security group"
  type        = string
  default     = ""
}

variable "route_table_ids" {
  description = "Route table ids"
  type        = list(string)
  default     = []
}
