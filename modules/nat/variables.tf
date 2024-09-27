variable "fck_nat_settings" {
  description = "Settings for fck-nat module https://registry.terraform.io/modules/RaJiska/fck-nat/aws/latest"
  type = object({
    instance_type     = string
    use_spot          = optional(bool)
    high_availability = optional(bool)
  })
  default = {
    instance_type = "t4g.nano"
  }
}

variable "subnet_count" {
  description = "Number of subnets your VPC has, one NAT will be created per subnet"
  type        = number
  nullable    = true
}

variable "vpc_id" {
  description = "ID of VPC"
  type        = string
}

variable "public_subnet_ids" {
  description = "List of public subnet ids"
  type        = list(string)
}

variable "private_route_table_ids" {
  description = "So services in private subnets can be routed to the NAT"
  type        = list(string)
}
