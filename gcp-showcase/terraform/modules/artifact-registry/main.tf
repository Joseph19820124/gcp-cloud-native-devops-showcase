# One Docker repository per environment. Images are named
# <region>-docker.pkg.dev/<project>/<name_prefix>/<service>:<tag>.
resource "google_artifact_registry_repository" "this" {
  location      = var.region
  repository_id = var.name_prefix
  format        = "DOCKER"
  description   = "Container images for ${var.name_prefix}"

  cleanup_policies {
    id     = "expire-untagged"
    action = "DELETE"
    condition {
      tag_state  = "UNTAGGED"
      older_than = "1209600s" # 14 days
    }
  }
}
