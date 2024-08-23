variable "bucket_name" {
  description = "Name of S3 Bucket"
  type        = string
}

variable "website_config" {
  description = "Website configuration"
  type = object({
    redirect_to = optional(string) // Will include a index.html document
    is_website  = optional(bool)   // Specify if bucket should redirect to another bucket
  })
  default = {
    redirect_to = null
    is_website  = false
  }
}

variable "bucket_access_and_policy" {
  description = "Specify who can access the bucket. Can one of 'public', 'cloudflare'"
  type        = string
  default     = null
  nullable    = true
}
