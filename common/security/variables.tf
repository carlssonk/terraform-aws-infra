variable "networking_outputs" {
  description = "All outputs from the networking module"
  type        = any
}

variable "reverse_proxy_type" {
  description = "nginx|alb - nginx will use a custom ec2 instance with a public Elastic IP, as a replacement for alb because its cheaper"
  type        = string
}
