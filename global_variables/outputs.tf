// We expose some variables "globally" so we avoid passing them to module arguments everywhere

variable organization { default = null }
output "organization" {
  value = var.organization
}