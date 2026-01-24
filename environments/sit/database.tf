resource "google_sql_database_instance" "sit_db" {
  name             = "sit-postgres-instance"
  database_version = "POSTGRES_15"
  region           = var.region
  
  depends_on = [module.networking] 

  settings {
    tier = "db-f1-micro"
    ip_configuration {
      ipv4_enabled                                  = false
      private_network                               = module.networking.vpc_id
      enable_private_path_for_google_cloud_services = true
    }
  }
}