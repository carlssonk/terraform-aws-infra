variable "aws_account_id" {
  description = "AWS Account ID"
}

variable "document_name" {
  description = "Name of AWS SSM Document"
}

data "aws_iam_policy_document" "this" {
  statement {
    actions = concat(
      [
        "ssm:CreateDocument",
        "ssm:DeleteDocument",
        "ssm:UpdateDocument",
        "ssm:CreateAssociation",
        "ssm:Describe*",
        "ssm:Get*",
        "ssm:List*",
      ]
    )
    resources = ["arn:aws:ssm:eu-north-1:${var.aws_account_id}:document/${var.document_name}"]
    effect    = "Allow"
  }

  statement {
    actions = concat(
      [
        "iam:PassRole"
      ]
    )
    resources = ["arn:aws:iam::${var.aws_account_id}:role/terraform-execution-role"]
    effect    = "Allow"
  }
}

output "policy_document" {
  value = data.aws_iam_policy_document.this.json
}
