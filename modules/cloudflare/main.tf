terraform {
  required_providers {
    cloudflare = {
      source = "cloudflare/cloudflare"
    }
  }
}

variable "workflow_step" {}

module "resources" {
  count                 = var.workflow_step == "resources" ? 1 : 0
  source                = "./resources"
  root_domain           = var.root_domain
  s3_subdomain_endpoint = var.s3_subdomain_endpoint
  s3_apex_endpoint      = var.s3_apex_endpoint
}
