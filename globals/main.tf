data "local_file" "globals" {
  filename = "${path.root}/globals.json"
}

locals {
  json = jsondecode(data.local_file.globals.content)
}

output "var" {
  value = local.json
}

output "run_iam" {
  value = local.json.workflow_step == "iam" ? 1 : 0
}

output "run_resources" {
  value = local.json.workflow_step == "resources" ? 1 : 0
}
