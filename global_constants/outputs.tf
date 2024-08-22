// We expose some variables "globally" so we avoid passing them to module as arguments everywhere

variable "organization" {
  default = "foobar"
}

output "organization" {
  value = var.organization
}