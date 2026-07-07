terraform {
  backend "gcs" {
    bucket = "showcase-tfstate-devops-showcase-025124"
    prefix = "dev"
  }
}
