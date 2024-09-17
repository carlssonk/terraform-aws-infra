resource "aws_cloudwatch_log_group" "thi" {
  name              = var.log_group_name
  retention_in_days = 30
}
