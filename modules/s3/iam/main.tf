variable "bucket_name" {
  description = "Name of S3 Bucket"
}
variable "bucket_access_and_policy" {
  description = "Specify who can access the bucket. Can one of 'public', 'cloudflare'"
}
variable "website_config" {
  description = "Website configuration"
}

data "aws_iam_policy_document" "this" {
  statement {
    actions = concat(
      [
        "s3:CreateBucket",
        "s3:DeleteBucket",
        "s3:Get*",
        "s3:List*"
      ],
      var.website_config.is_website || var.website_config.redirect_to != null ? [
        "s3:*BucketWebsite",
      ] : [],
      var.bucket_access_and_policy != null ? [
        "s3:*PublicAccessBlock",
        "s3:*BucketPolicy"
      ] : []
    )
    resources = [
      "arn:aws:s3:::${var.bucket_name}",
      "arn:aws:s3:::${var.bucket_name}/*"
    ]
    effect = "Allow"
  }
}

output "policy_document" {
  value = data.aws_iam_policy_document.this.json
}
