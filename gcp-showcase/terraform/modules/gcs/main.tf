resource "google_storage_bucket" "this" {
  name          = "${var.name_prefix}-${var.project_id}-assets"
  location      = var.location
  force_destroy = var.force_destroy

  uniform_bucket_level_access = true

  versioning {
    enabled = true
  }

  public_access_prevention = "enforced"
}
