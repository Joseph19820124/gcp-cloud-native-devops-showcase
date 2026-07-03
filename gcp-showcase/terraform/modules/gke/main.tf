resource "google_container_cluster" "this" {
  name     = "${var.name_prefix}-gke"
  location = var.location

  network    = var.network_name
  subnetwork = var.subnet_name

  # VPC-native (alias IP) cluster using the subnet's secondary ranges
  ip_allocation_policy {
    cluster_secondary_range_name  = var.pods_range_name
    services_secondary_range_name = var.services_range_name
  }

  # We manage the node pool separately, so remove the default one.
  remove_default_node_pool = true
  initial_node_count       = 1

  release_channel {
    channel = var.release_channel
  }

  # Private nodes, public control-plane endpoint (simple to reach from CI).
  private_cluster_config {
    enable_private_nodes    = true
    enable_private_endpoint = false
    master_ipv4_cidr_block  = var.master_cidr
  }

  workload_identity_config {
    workload_pool = "${var.project_id}.svc.id.goog"
  }

  deletion_protection = var.deletion_protection
}

resource "google_service_account" "nodes" {
  account_id   = "${var.name_prefix}-gke-nodes"
  display_name = "GKE nodes for ${var.name_prefix}"
}

# Least-privilege roles the kubelet/agents need
resource "google_project_iam_member" "node_roles" {
  for_each = toset([
    "roles/logging.logWriter",
    "roles/monitoring.metricWriter",
    "roles/monitoring.viewer",
    "roles/artifactregistry.reader",
  ])
  project = var.project_id
  role    = each.value
  member  = "serviceAccount:${google_service_account.nodes.email}"
}

resource "google_container_node_pool" "default" {
  name     = "${var.name_prefix}-default"
  location = var.location
  cluster  = google_container_cluster.this.name

  node_count = var.node_count

  autoscaling {
    min_node_count = var.min_node_count
    max_node_count = var.max_node_count
  }

  management {
    auto_repair  = true
    auto_upgrade = true
  }

  node_config {
    machine_type    = var.machine_type
    disk_size_gb    = var.disk_size_gb
    disk_type       = "pd-standard"
    service_account = google_service_account.nodes.email
    oauth_scopes    = ["https://www.googleapis.com/auth/cloud-platform"]

    workload_metadata_config {
      mode = "GKE_METADATA"
    }

    labels = {
      env = var.name_prefix
    }
  }
}
