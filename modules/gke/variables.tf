variable "project_id" {
  description = "The GCP Project ID"
  type        = string
}

variable "env_name" {
  description = "The environment name"
  type        = string
}

variable "region" {
  description = "GCP Region"
  type        = string
}

variable "vpc_name" {
  description = "Name of the VPC to deploy into"
  type        = string
}

variable "subnet_name" {
  description = "Name of the Subnet to deploy into"
  type        = string
}

variable "node_service_account" {
  description = "Email of the Service Account for GKE nodes"
  type        = string
}