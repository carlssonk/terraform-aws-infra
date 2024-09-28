resource "aws_s3_bucket" "this" {
  bucket        = var.bucket_name
  force_destroy = var.force_destroy
}

resource "aws_s3_bucket_website_configuration" "this" {
  count  = var.website_config.is_website || var.website_config.redirect_to != null ? 1 : 0
  bucket = aws_s3_bucket.this.id

  dynamic "index_document" {
    for_each = var.website_config.is_website ? ["x"] : []
    content {
      suffix = "index.html"
    }
  }

  dynamic "redirect_all_requests_to" {
    for_each = var.website_config.redirect_to != null ? ["x"] : []
    content {
      host_name = var.website_config.redirect_to
      protocol  = "https"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "this" {
  count  = var.bucket_access_and_policy == "public" || var.bucket_access_and_policy == "cloudflare" ? 1 : 0
  bucket = aws_s3_bucket.this.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

module "globals" {
  source = "../../globals"
}

locals {
  policy_types = {
    public = {
      Effect    = "Allow"
      Principal = "*"
      Action    = "s3:GetObject"
      Resource  = "${aws_s3_bucket.this.arn}/*"
    }
    cloudflare = {
      Effect    = "Allow"
      Principal = "*"
      Action    = "s3:GetObject"
      Resource  = "${aws_s3_bucket.this.arn}/*"
      Condition = {
        IpAddress = {
          "aws:SourceIp" = module.globals.var.cloudflare_all_ip_ranges
        }
      }
    }
    default = null
  }

  policy_statement = lookup(local.policy_types, coalesce(var.bucket_access_and_policy, "default"), null)

  policy_statement_combined = concat(
    local.policy_statement != null ? [local.policy_statement] : [],
    var.custom_bucket_policy != null ? [var.custom_bucket_policy] : []
  )
}

resource "aws_s3_bucket_policy" "this" {
  count  = length(local.policy_statement_combined) > 0 ? 1 : 0
  bucket = aws_s3_bucket.this.id

  policy = jsonencode({
    Version   = "2012-10-17"
    Statement = local.policy_statement_combined
  })
}
