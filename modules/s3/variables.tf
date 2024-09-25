variable "bucket_name" {
  description = "Name of S3 Bucket"
  type        = string
}

variable "force_destroy" {
  description = "Bucket will be able to be destroyed even if its not empty"
  type        = bool
  default     = false
}

variable "website_config" {
  description = "Website configuration"
  type = object({
    redirect_to = optional(string)      // Will include a index.html document
    is_website  = optional(bool, false) // Specify if bucket should redirect to another bucket
  })
  default = {}
}

variable "bucket_access_and_policy" {
  description = "Specify who can access the bucket. Can one of 'public', 'cloudflare'"
  type        = string
  default     = null
  nullable    = true
}

variable "custom_bucket_policy" {
  description = "Bucket policy document"
  type        = any
  default     = null
}
