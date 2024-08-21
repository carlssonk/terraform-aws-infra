module "iam" {
  source = "./iam"
}

resource "time_sleep" "wait_5_seconds" {
  depends_on = [module.iam]
  create_duration = "5s"
}

module "resources" {
  source = "./resources"
  bucket_name = var.bucket_name
  is_public_website = var.is_public_website
  depends_on = [time_sleep.wait_5_seconds]
}

