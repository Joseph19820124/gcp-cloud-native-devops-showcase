terraform {
  required_version = ">= 1.6.0"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
}

locals {
  name_prefix = "showcase-${var.environment}"
}

module "network" {
  source      = "../../modules/network"
  name_prefix = local.name_prefix
  region      = var.region
}

module "gke" {
  source              = "../../modules/gke"
  name_prefix         = local.name_prefix
  project_id          = var.project_id
  location            = var.zone
  network_name        = module.network.network_name
  subnet_name         = module.network.subnet_name
  pods_range_name     = module.network.pods_range_name
  services_range_name = module.network.services_range_name
  machine_type        = var.node_machine_type
  node_count          = var.node_count
  min_node_count      = var.node_min_count
  max_node_count      = var.node_max_count
  deletion_protection = var.deletion_protection
}

module "cloudsql" {
  source                 = "../../modules/cloudsql"
  name_prefix            = local.name_prefix
  region                 = var.region
  network_id             = module.network.network_id
  private_vpc_connection = module.network.private_vpc_connection
  tier                   = var.db_tier
  availability_type      = var.db_availability_type
  db_password            = var.db_password
  deletion_protection    = var.deletion_protection

  # Private IP requires the servicenetworking peering to exist first.
  depends_on = [module.network]
}

module "artifact_registry" {
  source      = "../../modules/artifact-registry"
  name_prefix = local.name_prefix
  region      = var.region
}

module "gcs" {
  source      = "../../modules/gcs"
  name_prefix = local.name_prefix
  project_id  = var.project_id
}
