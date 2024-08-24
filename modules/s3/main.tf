module "globals" {
  source = "../../globals"
}

module "generate_policy_document" {
  count                    = module.globals.run_iam
  source                   = "./iam"
  bucket_name              = var.bucket_name
  bucket_access_and_policy = var.bucket_access_and_policy
  website_config           = var.website_config
  depends_on               = [module.globals]
}

module "resources" {
  count                    = module.globals.run_resources
  source                   = "./resources"
  bucket_name              = var.bucket_name
  bucket_access_and_policy = var.bucket_access_and_policy
  website_config           = var.website_config
  depends_on               = [module.globals]
}

output "policy_document" {
  value = try(module.generate_policy_document[0].policy_document, null)
}

output "website_endpoint" {
  value = try(module.resources[0].website_endpoint, null)
}
