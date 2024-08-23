variable "table_name_full" {
  description = "Name of dynamodb table prefixed with organization and suffixed with environment"
}

resource "aws_dynamodb_table" "this" {
  name         = var.table_name_full
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }
}
