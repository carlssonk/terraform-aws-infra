module "iam" {
  source = "./iam"
}

resource "null_resource" "iam_change_trigger" {
  triggers = {
    iam_module_output = jsonencode(module.iam)
  }
}

resource "time_sleep" "wait_5_seconds" {
  count = null_resource.iam_change_trigger.triggers != null_resource.iam_change_trigger.triggers_old ? 1 : 0
  depends_on = [module.iam]
  create_duration = "5s"
}

module "main" {
  source = "./main"
  bucket_name = var.bucket_name
  is_public_website = var.is_public_website
  depends_on = [time_sleep.wait_5_seconds]
}

