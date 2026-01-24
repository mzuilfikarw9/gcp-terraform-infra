provider "google" {
  project = var.project_id
  region  = var.region
}

module "networking" {
  source      = "../../modules/network"
  project_id  = var.project_id
  env_name    = var.env_name
  region      = var.region
  subnet_cidr = var.subnet_cidr
}

module "gke" {
  source               = "../../modules/gke"
  project_id           = var.project_id
  region               = var.region
  env_name             = var.env_name
  node_service_account = var.node_service_account
  vpc_id               = module.networking.vpc_id
  subnet_id            = module.networking.subnet_id
}