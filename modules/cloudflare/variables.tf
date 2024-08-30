variable "root_domain" {
  description = "The root domain name to route to the S3 bucket"
  type        = string
}

variable "s3_subdomain_endpoint" {
  description = "The S3 bucket (www) website endpoint"
  type        = string
}

variable "s3_apex_endpoint" {
  description = "The S3 bucket (root) website endpoint"
  type        = string
}
