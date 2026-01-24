resource "google_container_cluster" "primary" {
  name     = "${var.env_name}-gke"
  
  location = "${var.region}-a" 

  network    = var.vpc_name
  subnetwork = var.subnet_name

  remove_default_node_pool = true
  initial_node_count       = 1
  deletion_protection      = false

  # CLUSTER CONFIG: MUST match what is currently running (Standard/Non-Preemptible)
  # Do NOT add preemptible = true here, or it forces a destroy.
  node_config {
    disk_size_gb = 50             
    disk_type    = "pd-standard"  
    machine_type = "e2-standard-2"
    
    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]
  }

  ip_allocation_policy {
    cluster_secondary_range_name  = "gke-pods"
    services_secondary_range_name = "gke-services"
  }

  private_cluster_config {
    enable_private_nodes    = true
    enable_private_endpoint = false
    master_ipv4_cidr_block  = "172.16.0.0/28"
  }

  workload_identity_config {
    workload_pool = "${var.project_id}.svc.id.goog"
  }
}

# NODE POOL: This is where we scale up and use Spot VMs
resource "google_container_node_pool" "primary_nodes" {
  name       = "${var.env_name}-node-pool"
  
  location   = "${var.region}-a"
  
  cluster    = google_container_cluster.primary.name
  
  # SCALING UP: Changed from 1 to 2
  node_count = 2

  node_config {
    preemptible  = true # Keep this TRUE here for cost savings
    machine_type = "e2-standard-2"
    
    disk_size_gb = 50
    disk_type    = "pd-standard"

    service_account = var.node_service_account
    oauth_scopes    = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]
    
    workload_metadata_config {
      mode = "GKE_METADATA"
    }
  }
}