bucket         = "${org}-terraform-state-bucket-${env}"
key            = "terraform.tfstate"
region         = "eu-north-1"
dynamodb_table = "${org}-terraform-lock-table-${env}"
encrypt        = true