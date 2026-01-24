resource "google_sql_database_instance" "sit_db" {
  name             = "sit-postgres-instance"
  database_version = "POSTGRES_15"
  region           = var.region

  settings {
    tier = "db-f1-micro" # Lowest cost for SIT
    ip_configuration {
      ipv4_enabled    = false # Keep it private
      private_network = module.network.vpc_id # Connect to your VPC
    }
  }
}