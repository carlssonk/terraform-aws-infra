data "local_file" "globals" {
  filename = "${path.root}/globals.json"
}

output "globals" {
  value = jsondecode(data.local_file.globals.content)
}