variable "name_prefix" {
  type = string
}

variable "region" {
  type = string
}

variable "network_id" {
  description = "VPC self_link/id for the private IP configuration"
  type        = string
}

# Ensures the private-services peering exists before the instance is created.
variable "private_vpc_connection" {
  type    = string
  default = ""
}

variable "database_version" {
  type    = string
  default = "POSTGRES_16"
}

variable "tier" {
  type    = string
  default = "db-f1-micro"
}

variable "availability_type" {
  description = "ZONAL or REGIONAL"
  type        = string
  default     = "ZONAL"
}

variable "disk_size" {
  type    = number
  default = 10
}

variable "backups_enabled" {
  type    = bool
  default = true
}

variable "db_name" {
  type    = string
  default = "helloworld"
}

variable "db_username" {
  type    = string
  default = "helloworld"
}

variable "db_password" {
  type      = string
  sensitive = true
}

variable "deletion_protection" {
  type    = bool
  default = false
}
