variable "bucket_name" {}

variable "is_public_website" {
  description = "Will configure bucket to be a public website"
  type = bool
  default = false
}