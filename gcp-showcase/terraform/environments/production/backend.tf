terraform {
  backend "gcs" {
    bucket = "showcase-tfstate-gwsjoseph0326"
    prefix = "production"
  }
}
