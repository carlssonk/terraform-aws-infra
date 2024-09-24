variable "workflow_step" {
  description = "iam|resources"
  type        = string
}

variable "app_name" {
  description = "Name"
  type        = string
}

variable "root_domain" {
  description = "Root domain name"
  type        = string
}

variable "subdomain" {
  description = "Subdomains. Use 'www' if website is root"
  type        = string
}

variable "github_repo_name" {
  description = "Repository name for deployment policy. '[github name]/[repo name]'"
  type        = string
}
