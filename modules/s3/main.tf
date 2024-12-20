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
  bucket = aws_s3_bucket.this.id

  block_public_acls       = var.block_public_acls != null ? var.block_public_acls : var.is_public ? false : true
  block_public_policy     = var.block_public_policy != null ? var.block_public_policy : var.is_public ? false : true
  ignore_public_acls      = var.ignore_public_acls != null ? var.ignore_public_acls : var.is_public ? false : true
  restrict_public_buckets = var.restrict_public_buckets != null ? var.restrict_public_buckets : var.is_public ? false : true
}

module "globals" {
  source = "../../globals"
}

locals {
  policy_types = {
    public = {
      Effect    = "Allow"
      Principal = "*"
      Action    = try(var.bucket_policy.permissions, [])
      Resource = [
        aws_s3_bucket.this.arn,
        "${aws_s3_bucket.this.arn}/*"
      ]
    }
    cloudflare = {
      Effect    = "Allow"
      Principal = "*"
      Action    = try(var.bucket_policy.permissions, [])
      Resource = [
        aws_s3_bucket.this.arn,
        "${aws_s3_bucket.this.arn}/*"
      ]
      Condition = {
        IpAddress = {
          "aws:SourceIp" = module.globals.var.cloudflare_all_ip_ranges
        }
      }
    }
    default = null
  }

  policy_statement = lookup(local.policy_types, coalesce(try(var.bucket_policy.name, null), "default"), null)

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
