module "s3" {
  source = "../../modules/s3"
  bucket_name = "${var.organization}-portfolio-${var.environment}"
  is_public_website = true
}