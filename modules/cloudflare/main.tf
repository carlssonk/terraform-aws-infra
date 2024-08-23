module "globals" {
  source = "../../globals"
}

module "resources" {
  count               = module.globals.run_resources
  source              = "./resources"
  domain_name         = var.domain_name
  s3_website_endpoint = var.s3_website_endpoint
  domain_zone_id      = var.domain_zone_id
}
