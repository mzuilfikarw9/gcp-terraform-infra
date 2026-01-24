provider "google" {
  project = var.project_id
  region  = var.region
}

# 1. Create the Service Account for Nodes
resource "google_service_account" "gke_node_sa" {
  account_id   = "gke-node-sa-sit"
  display_name = "GKE Node Service Account - SIT"
}

# 2. Call Network Module
module "networking" {
  source      = "../../modules/network"
  env_name    = "sit"
  region      = var.region
  subnet_cidr = "10.0.0.0/20"
}

# 3. Call GKE Module
module "gke" {
  source               = "../../modules/gke"
  project_id           = var.project_id
  env_name             = "sit"
  region               = var.region
  vpc_name             = module.networking.vpc_name
  subnet_name          = module.networking.subnet_name
  node_service_account = google_service_account.gke_node_sa.email
}