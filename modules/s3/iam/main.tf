variable "bucket_name_full" {
  description = "Name of S3 Bucket prefixed with organization and suffixed with envrionment"
  type        = string
}

variable "is_public_website" {
  description = "Will configure bucket to be publicly accessible"
  type        = string
  default     = false
}

data "aws_iam_policy_document" "this" {
  statement {
    actions = concat(
      [
        "s3:CreateBucket",
        "s3:DeleteBucket",
        "s3:HeadBucket",
        "s3:Get*",
        "s3:List*"
      ],
      var.is_public_website ? [
        "s3:*BucketWebsite",
        "s3:*PublicAccessBlock",
        "s3:*BucketPolicy"
      ] : []
    )
    resources = [
      "arn:aws:s3:::${var.bucket_name_full}",
      "arn:aws:s3:::${var.bucket_name_full}/*"
    ]
    effect = "Allow"
  }
}

output "policy_document" {
  value = data.aws_iam_policy_document.this.json
}
