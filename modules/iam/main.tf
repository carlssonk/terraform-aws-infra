variable "name" {}
variable "policy_document" {}

resource "aws_iam_policy" "this" {
  name = "terraform-${var.name}-policy"
  description = "Composite policy for Terraform execution role"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = jsondecode(var.policy_document).Statement
  })
}

resource "aws_iam_role_policy_attachment" "this" {
  role = "terraform-execution-role"
  policy_arn = aws_iam_policy.this.arn
}