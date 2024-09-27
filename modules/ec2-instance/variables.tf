variable "ami" {
  description = "The AMI to use for the instance"
  type        = string
}

variable "instance_type" {
  description = "The type of instance to start"
  type        = string
}

variable "user_data" {
  description = "The user data to provide when launching the instance"
  type        = string
  default     = ""
}

variable "name" {
  description = "Name to be used on all resources as prefix"
  type        = string
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}

variable "subnet_ids" {
  description = "List of subnet ID's to use"
  type        = list(string)
}

variable "security_group_id" {
  description = "ID of Security Group"
  type        = string
}

variable "use_spot" {
  description = "Spot is cheaper than on-demand but is less available"
  type        = bool
  default     = false
}

variable "spot_max_price" {
  description = "Max bid price for spot, should not be above regulare on-demand price and not be too low since it will cause lower availability. null will set it to same as on-demand price"
  type        = number
  default     = null
}

variable "spot_instance_type" {
  description = "Instance type"
  type        = string
  default     = null
}

variable "spot_instance_interruption_behavior" {
  description = "terminate,hibernate,stop"
  type        = string
  default     = null
}
