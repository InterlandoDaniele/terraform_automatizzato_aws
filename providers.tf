# Terraform Block
terraform {
  required_version = ">= 1.6"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.89.0"
    }
    null = {
      source  = "hashicorp/null"
      version = "~> 3.0"
    }
    local = {
      source  = "hashicorp/local"
      version = "~> 2.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
  }
  backend "s3" {}
}

# Provider Block
provider "aws" {
  region = var.aws_region
}

provider "null" {}


locals {
  common_tags = {
    Terraform   = "true"
    Client      = var.business_division
    Environment = var.environment
    Version     = var.version_release
  }
}

/*
Note-1:  AWS Credentials Profile (profile = "default") configured on your local desktop terminal  
$HOME/.aws/credentials
*/
