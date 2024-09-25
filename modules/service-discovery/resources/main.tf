resource "aws_service_discovery_http_namespace" "this" {
  name = var.namespace_name
}
