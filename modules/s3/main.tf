module "globals" {
  source = "../../globals"
}

resource "terraform_data" "run_iam" {
  input = module.globals.run_iam
}
resource "terraform_data" "run_resources" {
  input = module.globals.run_resources
}


module "generate_policy_document" {
  count                    = terraform_data.run_iam.output
  source                   = "./iam"
  bucket_name              = var.bucket_name
  bucket_access_and_policy = var.bucket_access_and_policy
  website_config           = var.website_config
}

module "resources" {
  count                    = terraform_data.run_resources
  source                   = "./resources"
  bucket_name              = var.bucket_name
  bucket_access_and_policy = var.bucket_access_and_policy
  website_config           = var.website_config
}

output "policy_document" {
  value = try(module.generate_policy_document[0].policy_document, null)
}

output "website_endpoint" {
  value = try(module.resources[0].website_endpoint, null)
}
