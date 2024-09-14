variable "workflow_step" {
  description = "iam|resources"
  type        = string
}

variable "root_domain" {
  description = "Domain name excluding subdomains"
  type        = string
}

variable "domain_name" {
  description = "Domain name including subdomains"
  type        = string
}
