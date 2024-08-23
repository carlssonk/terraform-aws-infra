variable "domain_name" {
  description = "The domain name to route to the S3 bucket"
  type        = string
}

variable "s3_website_endpoint" {
  description = "The S3 bucket website endpoint"
  type        = string
}
