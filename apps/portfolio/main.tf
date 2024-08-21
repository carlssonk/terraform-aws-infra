module "s3" {
  source = "../../modules/s3"
  bucket_name = "portfolio"
  is_public_website = true
}

module "s3-2" {
  source = "../../modules/s3"
  bucket_name = "portfolio-2"
  is_public_website = true
}