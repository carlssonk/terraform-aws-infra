variable "name" {
  description = "VPC name"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  default     = "10.0.0.0/16"
}

locals {
  # The DNS server for a VPC is always at the base of the VPC network range, plus 2
  dns_resolver_ip = cidrhost(var.vpc_cidr, 2) // eg. 10.0.0.0/16 -> 10.0.0.2
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for the public subnets"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks for the private subnets"
  type        = list(string)
  default     = ["10.0.3.0/24", "10.0.4.0/24"]
}
