module "globals" {
  source = "../../../globals"
}

resource "aws_dynamodb_table" "this" {
  name         = "${module.globals.var.ORGANIZATION}-${var.table_name}-${terraform.workspace}"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }
}
