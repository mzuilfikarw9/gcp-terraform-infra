resource "google_container_cluster" "primary" {
  name     = "${var.env_name}-gke"
  location = var.region # Regional cluster (High Availability Control Plane)

  network    = var.vpc_name
  subnetwork = var.subnet_name

  # We create the cluster with no default node pool to avoid drift
  remove_default_node_pool = true
  initial_node_count       = 1

  # NETWORK CONFIGURATION
  ip_allocation_policy {
    cluster_secondary_range_name  = "gke-pods"
    services_secondary_range_name = "gke-services"
  }

  private_cluster_config {
    enable_private_nodes    = true
    enable_private_endpoint = false # Keep false for SIT so you can access it easily. True for Prod.
    master_ipv4_cidr_block  = "172.16.0.0/28"
  }

  workload_identity_config {
    workload_pool = "${var.project_id}.svc.id.goog"
  }
}

# NODE POOL - Optimized for SIT (Spot Instances)
resource "google_container_node_pool" "primary_nodes" {
  name       = "${var.env_name}-node-pool"
  location   = var.region
  cluster    = google_container_cluster.primary.name
  node_count = 1 # 1 node per zone (3 total if using 3 zones)

  node_config {
    preemptible  = true # SPOT INSTANCES -> SAVES MONEY
    machine_type = "e2-standard-2"

    # Security Best Practice: Use least-privilege Service Account
    service_account = var.node_service_account
    oauth_scopes    = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]
    
    workload_metadata_config {
      mode = "GKE_METADATA"
    }
  }
}