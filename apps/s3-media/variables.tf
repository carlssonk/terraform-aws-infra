variable "workflow_step" {
  description = "iam|resources"
  type        = string
}

variable "bucket_name" {
  description = "Name"
  type        = string
}

variable "subdomain" {
  description = "Subdomains. Use 'www' if website is root"
  type        = string
}

variable "root_domain" {
  description = "Root domain name"
  type        = string
}
