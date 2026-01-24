resource "google_service_account" "gke_node_sa" {
  account_id   = "gke-node-sa-sit"
  project      = var.project_id
  display_name = "GKE Node Service Account - SIT"
}