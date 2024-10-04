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

variable "is_public" {
  description = "If true all props in access block will be set to false"
  type        = bool
  default     = false
}

variable "custom_bucket_policy" {
  description = "Bucket policy document"
  type        = any
  default     = null
}

variable "bucket_policy" {
  description = "Predefined bucket policies"
  type = object({
    name        = string
    permissions = list(string)
  })
  default = {}
}
