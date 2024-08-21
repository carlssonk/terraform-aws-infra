variable "bucket_name_full" {}
variable "is_public_website" {}

resource "aws_s3_bucket" "this" {
  bucket = var.bucket_name_full
}

resource "aws_s3_bucket_website_configuration" "this" {
  count = var.is_public_website ? 1 : 0
  bucket = aws_s3_bucket.this.id

  index_document {
    suffix = "index.html"
  }
}

resource "aws_s3_bucket_public_access_block" "this" {
  count = var.is_public_website ? 1 : 0
  bucket = aws_s3_bucket.this.id

  block_public_acls = false
  block_public_policy = false
  ignore_public_acls = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_policy" "this" {
  count = var.is_public_website ? 1 : 0
  bucket = aws_s3_bucket.this.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = "*"
        Action = "s3:GetObject"
        Resource = "${aws_s3_bucket.this.arn}/*"
      }
    ]
  })

  depends_on = [
    aws_s3_bucket.this,
    aws_s3_bucket_public_access_block.this
  ]
}