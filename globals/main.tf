data "local_file" "globals" {
  filename = "${path.root}/globals.json"
}
locals {
  globals = jsondecode(data.local_file.globals.content)
}

output "globals" {
  value = local.globals
}