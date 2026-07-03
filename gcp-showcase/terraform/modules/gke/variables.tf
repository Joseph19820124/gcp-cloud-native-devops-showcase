variable "name_prefix" {
  type = string
}

variable "project_id" {
  type = string
}

variable "location" {
  description = "Zone (e.g. us-central1-a) for a zonal cluster, or region for regional"
  type        = string
}

variable "network_name" {
  type = string
}

variable "subnet_name" {
  type = string
}

variable "pods_range_name" {
  type = string
}

variable "services_range_name" {
  type = string
}

variable "master_cidr" {
  description = "CIDR for the private control-plane endpoint"
  type        = string
  default     = "172.16.0.0/28"
}

variable "release_channel" {
  type    = string
  default = "REGULAR"
}

variable "machine_type" {
  type    = string
  default = "e2-medium"
}

variable "disk_size_gb" {
  type    = number
  default = 50
}

variable "node_count" {
  type    = number
  default = 2
}

variable "min_node_count" {
  type    = number
  default = 1
}

variable "max_node_count" {
  type    = number
  default = 4
}

variable "deletion_protection" {
  type    = bool
  default = false
}
