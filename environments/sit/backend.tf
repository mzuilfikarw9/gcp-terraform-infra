terraform {
  backend "gcs" {
    bucket  = "tf-state-my-company-sit"
    prefix  = "terraform/state"
  }
}