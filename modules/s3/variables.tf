variable "bucket_name" {
  description = "Name of S3 Bucket"
  type        = string
}

variable "is_public_website" {
  description = "Will configure bucket to be publicly accessible"
  type        = string
  default     = false
}
