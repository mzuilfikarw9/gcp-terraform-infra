resource "google_container_cluster" "primary" {
  name     = "${var.env_name}-gke"
  location = "${var.region}-a"
  project  = var.project_id

  network    = var.vpc_id
  subnetwork = var.subnet_id

  remove_default_node_pool = true
  initial_node_count       = 2
  deletion_protection      = true 

  private_cluster_config {
    enable_private_nodes    = true
    enable_private_endpoint = false
    master_ipv4_cidr_block  = "172.16.0.0/28"
  }

  lifecycle {
    ignore_changes = [node_config, initial_node_count]
  }
}

resource "google_container_node_pool" "primary_nodes" {
  name       = "${var.env_name}-node-pool"
  location   = "${var.region}-a"
  cluster    = google_container_cluster.primary.name
  project    = var.project_id
#   node_count = 2

autoscaling {
    min_node_count = 2
    max_node_count = 6
  }

  node_config {
    machine_type = "e2-standard-2"
    preemptible  = false
    service_account = var.node_service_account
    oauth_scopes    = ["https://www.googleapis.com/auth/cloud-platform"]
  }
}