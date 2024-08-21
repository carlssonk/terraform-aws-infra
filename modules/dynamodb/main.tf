variable table_name {}
variable "organization" {}

locals {
  full_table_name = "${var.organization}-${var.table_name}-${terraform.workspace}"
}


resource "aws_dynamodb_table" "this" {
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
      aws_dynamodb_table.this.arn,
      "${aws_dynamodb_table.this.arn}/*"
    ]
    effect = "Allow"
  }
}

output "table_policy_json" {
  value = data.aws_iam_policy_document.table_policy.json
}