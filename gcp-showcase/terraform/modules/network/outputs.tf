output "network_id" {
  value = google_compute_network.this.id
}

output "network_name" {
  value = google_compute_network.this.name
}

output "subnet_name" {
  value = google_compute_subnetwork.this.name
}

output "pods_range_name" {
  value = "pods"
}

output "services_range_name" {
  value = "services"
}

# Consumers (e.g. Cloud SQL) should depend on this to ensure the peering
# is established before they try to use a private IP.
output "private_vpc_connection" {
  value = google_service_networking_connection.this.id
}
