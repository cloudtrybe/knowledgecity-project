terraform {
  backend "s3" {
    bucket = "knowledgecity-infra"
    region = "me-south-1"
    key    = "terraform.tfstate"
  }
}
