variable "bucket_name" { 
  type = string
}

variable "is_public_website" {
  description = "Will configure bucket to be a public website"
  type = bool
  default = false
}

resource "aws_s3_bucket" "bucket" {
  bucket = var.bucket_name
}

resource "aws_s3_bucket_website_configuration" "bucket" {
  count = var.is_public_website ? 1 : 0
  bucket = aws_s3_bucket.bucket.id

  index_document {
    suffix = "index.html"
  }
}

resource "aws_s3_bucket_public_access_block" "bucket" {
  count = var.is_public_website ? 1 : 0
  bucket = aws_s3_bucket.bucket.id

  block_public_acls = false
  block_public_policy = false
  ignore_public_acls = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_policy" "bucket" {
  count = var.is_public_website ? 1 : 0
  bucket = aws_s3_bucket.bucket.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = "*"
        Action = "s3:GetObject"
        Resource = "${aws_s3_bucket.bucket.arn}/*"
      }
    ]
  })

  depends_on = [
    aws_s3_bucket.bucket,
    aws_s3_bucket_public_access_block.bucket
  ]
}