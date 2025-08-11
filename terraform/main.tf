terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

module "site-modules" {
  source       = "./modules"
  region       = var.aws_region
  lisa-env     = var.lisa-environment
  lisa-s3-site = var.lisa-s3-bucket-site
  lisa-s3-logs = var.lisa-s3-bucket-log
}


