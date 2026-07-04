variable "environment" {
  type    = string
  default = "dev"
}

variable "project_id" {
  type = string
}

variable "region" {
  type    = string
  default = "us-central1"
}

variable "zone" {
  description = "Zone for the (zonal) GKE cluster"
  type        = string
  default     = "us-central1-a"
}

variable "node_machine_type" {
  type    = string
  default = "e2-medium"
}

variable "node_count" {
  type    = number
  default = 2
}

variable "node_min_count" {
  type    = number
  default = 1
}

variable "node_max_count" {
  type    = number
  default = 5
}

variable "db_tier" {
  type    = string
  default = "db-f1-micro"
}

variable "db_availability_type" {
  type    = string
  default = "ZONAL"
}

variable "deletion_protection" {
  type    = bool
  default = false
}

variable "db_password" {
  type      = string
  sensitive = true
}
