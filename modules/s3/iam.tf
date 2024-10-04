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
      var.is_public == true ? [
        "s3:*PublicAccessBlock"
      ] : [],
      [
        "s3:*BucketPolicy"
      ]
    )
    resources = [
      "arn:aws:s3:::${var.bucket_name}",
      "arn:aws:s3:::${var.bucket_name}/*"
    ]
    effect = "Allow"
  }
}

output "policy_document" {
  value = try(data.aws_iam_policy_document.this.json, null)
}
