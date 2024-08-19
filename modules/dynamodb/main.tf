variable table_name {}
variable "organization" {}
variable "environment" {}

locals {
  full_table_name = "${var.organization}-${var.table_name}-${var.environment}"
}


resource "aws_dynamodb_table" "table" {
  name = local.full_table_name
  billing_mode = "PAY_PER_REQUEST"
  hash_key = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }
}

data "aws_iam_policy_document" "table_policy" {
  statement {
    actions = ["dynamodb:*"]
    resources = [
      aws_s3_bucket.this.arn,
      "${aws_s3_bucket.this.arn}/*"
    ]
    effect = "Allow"
  }
}

output "table_policy_json" {
  value = data.aws_iam_policy_document.table_policy.json
}