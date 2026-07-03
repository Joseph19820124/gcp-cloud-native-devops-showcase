variable "name_prefix" {
  type = string
}

variable "project_id" {
  type = string
}

variable "location" {
  type    = string
  default = "US"
}

variable "force_destroy" {
  description = "Allow terraform destroy to delete a non-empty bucket (demo convenience)"
  type        = bool
  default     = true
}
