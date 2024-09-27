variable "name" {
  description = "VPC name"
  type        = string
}

variable "enable_dns_hostnames" {
  description = "DNS Hostnames"
  type        = bool
}

variable "enable_dns_support" {
  description = "DNS Support"
  type        = bool
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
}

variable "use_single_subnet" {
  description = "Reduces costs associated with multiple NAT Gateways/instances and data transfer between AZs, but gives less availability/stability"
}
