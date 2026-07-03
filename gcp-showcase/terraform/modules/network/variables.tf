variable "name_prefix" {
  description = "Prefix used to name all networking resources"
  type        = string
}

variable "region" {
  type = string
}

variable "subnet_cidr" {
  description = "Primary CIDR for the node subnet"
  type        = string
  default     = "10.10.0.0/20"
}

variable "pods_cidr" {
  description = "Secondary range for GKE pods"
  type        = string
  default     = "10.20.0.0/16"
}

variable "services_cidr" {
  description = "Secondary range for GKE services"
  type        = string
  default     = "10.30.0.0/20"
}
