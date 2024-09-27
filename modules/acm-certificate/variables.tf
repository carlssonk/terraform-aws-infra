variable "domain_name" {
  type        = string
  description = "The domain name for the ACM certificate"
}

variable "subject_alternative_names" {
  type        = list(string)
  description = "A list of domains that should be SANs in the issued certificate"
  default     = []
}
