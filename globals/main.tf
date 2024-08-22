data "local_file" "globals" {
  filename = "${path.root}/globals.json"
}

output "var" {
  value = jsondecode(data.local_file.globals.content)
}