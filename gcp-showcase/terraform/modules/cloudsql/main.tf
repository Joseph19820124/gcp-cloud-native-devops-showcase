resource "google_sql_database_instance" "this" {
  name             = "${var.name_prefix}-postgres"
  database_version = var.database_version
  region           = var.region

  # Guard against accidental deletion in real environments (off for demo).
  deletion_protection = var.deletion_protection

  settings {
    tier              = var.tier
    availability_type = var.availability_type
    disk_size         = var.disk_size
    disk_autoresize   = true

    backup_configuration {
      enabled = var.backups_enabled
    }

    ip_configuration {
      # Private IP only — reachable from the GKE pods over VPC peering.
      ipv4_enabled    = false
      private_network = var.network_id
    }
  }
}

resource "google_sql_database" "app" {
  name     = var.db_name
  instance = google_sql_database_instance.this.name
}

resource "google_sql_user" "app" {
  name     = var.db_username
  instance = google_sql_database_instance.this.name
  password = var.db_password
}
