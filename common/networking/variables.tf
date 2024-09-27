variable "use_single_subnet" {
  description = "Reduces costs associated with multiple NAT Gateways/instances and data transfer between AZs, but gives less availability/stability"
}

variable "nat_type" {
  description = "fck-nat|null - Allows outbound traffic from services that are in private subnets. By default one nat per AZ will be created, set use_single_subnet to true to only use one"
  type        = string
  default     = null
}

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
