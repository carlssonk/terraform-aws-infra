output "website_endpoint" {
  value = try(aws_s3_bucket_website_configuration.this[0].website_endpoint, null)
}
