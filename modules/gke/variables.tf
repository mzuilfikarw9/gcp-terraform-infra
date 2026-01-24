variable "project_id" {
  type = string
}

variable "region" {
  type = string
}

variable "env_name" {
  type = string
}

variable "vpc_id" {
  type        = string
  description = "The ID of the VPC created by the network module"
}

variable "subnet_id" {
  type        = string
  description = "The ID of the Subnet created by the network module"
}

variable "node_service_account" {
  type = string
}