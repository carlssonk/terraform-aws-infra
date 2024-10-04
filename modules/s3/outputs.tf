output "website_endpoint" {
  value = try(aws_s3_bucket_website_configuration.this[0].website_endpoint, null)
}

output "bucket_regional_domain_name" {
  value = try(aws_s3_bucket.this[0].bucket_regional_domain_name, null)
}
