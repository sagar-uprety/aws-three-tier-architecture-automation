provider "aws" {
  region  = "us-east-1"

  default_tags {
    tags = {
      Created_by_tf = var.created_by_tf
      Environment = var.environment
      Application = var.application
    }
  }
}

terraform {
  required_version = ">= 1.9.7"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.71" # pin the major version to avoid breaking changes
    }
  }
  
  backend "s3" {
    bucket = "terraform-backend-personal-dev"
    region = "us-east-1"
    encrypt = true
    key = "aws-three-tier-wordpress/terraform.tfstate"
  }
}
