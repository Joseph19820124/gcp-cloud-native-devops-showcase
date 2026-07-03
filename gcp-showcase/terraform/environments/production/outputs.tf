output "cluster_name" {
  value = module.gke.cluster_name
}

output "cluster_location" {
  value = module.gke.cluster_location
}

output "db_private_ip" {
  value = module.cloudsql.private_ip
}

output "registry_url" {
  value = module.artifact_registry.repository_url
}

output "assets_bucket" {
  value = module.gcs.bucket_name
}
