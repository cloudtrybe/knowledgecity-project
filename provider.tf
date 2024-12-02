terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  backend "s3" {}
}

provider "vault" {
  address = "http://localhost:8200"
  token   = var.vault_token
}

data "vault_aws_access_credentials" "aws_cred" {
  backend = "aws"
  role    = "dev-role"
}

# Configure the AWS Provider
provider "aws" {
  region = var.region
}