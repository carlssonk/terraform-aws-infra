terraform {
  backend "s3" {}
}

module "portfolio" {
  source = "./apps/portfolio"
}