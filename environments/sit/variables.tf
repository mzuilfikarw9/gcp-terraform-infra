variable "project_id" {
  type        = string
  description = "The GCP Project ID"
}

variable "region" {
  type        = string
  description = "GCP region"
}

variable "env_name" {
  type        = string
  description = "Environment name (sit)"
}

variable "subnet_cidr" {
  type        = string
  description = "CIDR range for the subnet"
}

variable "node_service_account" {
  type        = string
  description = "The service account email for GKE nodes"
}