module "s3" {
  source = "../../modules/s3"
  bucket_name = "portfolio"
  is_public_website = true
}