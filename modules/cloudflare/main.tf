terraform {
  required_providers {
    cloudflare = {
      source = "cloudflare/cloudflare"
    }
  }
}

module "globals" {
  source = "../../globals"
}

module "resources" {
  count               = module.globals.run_resources
  source              = "./resources"
  root_domain         = var.root_domain
  s3_website_endpoint = var.s3_website_endpoint
}
