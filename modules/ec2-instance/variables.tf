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

variable "subnet_id" {
  description = "A subnet ID"
  type        = string
}

variable "security_group_id" {
  description = "ID of Security Group"
  type        = string
}
