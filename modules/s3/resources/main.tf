variable "bucket_name" {
  description = "Name of S3 Bucket"
}
variable "bucket_access_and_policy" {
  description = "Specify who can access the bucket. Can one of 'public', 'cloudflare'"
}
variable "website_config" {
  description = "Website configuration"
}

resource "aws_s3_bucket" "this" {
  bucket = var.bucket_name
}

resource "aws_s3_bucket_website_configuration" "this" {
  bucket = aws_s3_bucket.this.id

  dynamic "index_document" {
    for_each = var.website_config.is_website ? [1] : []
    content {
      suffix = "index.html"
    }
  }

  dynamic "redirect_all_requests_to" {
    for_each = var.website_config.redirect_to != null ? [1] : []
    content {
      host_name = var.website_config.redirect_to
      protocol  = "https"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "this" {
  count  = var.bucket_access_and_policy == "public" ? 1 : 0
  bucket = aws_s3_bucket.this.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

data "http" "cloudflare_ips_v4" {
  count = var.bucket_access_and_policy == "cloudflare" ? 1 : 0
  url   = "https://www.cloudflare.com/ips-v4"
  request_headers = {
    Accept = "text/plain"
  }
}

data "http" "cloudflare_ips_v6" {
  count = var.bucket_access_and_policy == "cloudflare" ? 1 : 0
  url   = "https://www.cloudflare.com/ips-v6"
  request_headers = {
    Accept = "text/plain"
  }
}

locals {
  policy_types = {
    public = {
      Effect    = "Allow"
      Principal = "*"
      Action    = "s3:GetObject"
      Resource  = "${aws_s3_bucket.this.arn}/*"
    },
    cloudflare = {
      Effect    = "Deny"
      Principal = "*"
      Action    = "s3:GetObject"
      Resource  = "${aws_s3_bucket.this.arn}/*"
      Condition = {
        NotIpAddress = {
          "aws:SourceIp" = concat(
            split("\n", chomp(try(data.http.cloudflare_ips_v4[0].response_body, ""))),
            split("\n", chomp(try(data.http.cloudflare_ips_v6[0].response_body, "")))
          )
        }
      }
    }
    default = null
  }

  policy_statement = lookup(local.policy_types, coalesce(var.bucket_access_and_policy, "default"), null)
}

resource "aws_s3_bucket_policy" "this" {
  count  = local.policy_statement != null ? 1 : 0
  bucket = aws_s3_bucket.this.id

  policy = jsonencode({
    Version   = "2012-10-17"
    Statement = [local.policy_statement]
  })
}

output "website_endpoint" {
  value = aws_s3_bucket_website_configuration.this.website_endpoint
}
