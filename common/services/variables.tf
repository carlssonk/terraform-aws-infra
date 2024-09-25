variable "networking_outputs" {
  description = "All outputs from the networking module"
  type        = any
}

variable "security_outputs" {
  description = "All outputs from the security module"
  type        = any
}

variable "root_domains" {
  description = "Map of all root domains"
  type        = map(any)
}

variable "reverse_proxy_type" {
  description = "nginx|alb - nginx will use a custom ec2 instance with a public Elastic IP, as a replacement for alb because its cheaper"
  type        = string
}
