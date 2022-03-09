terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "3.65.0"
    }
  }

  backend "s3" {
    profile = "YOUR_AWS_CREDENTIAL_PROFILE"
    region  = "us-east-1"
  }
}

provider "aws" {
  profile = "YOUR_AWS_CREDENTIAL_PROFILE"
  region  = "us-east-1"
}

variable "infra_env" {
  type        = string
  description = "Infrastructure Environment"
  default     = "production"
}

locals {
  cider_subnets = cidrsubnets("10.0.0.0/17", 4, 4, 4, 4, 4, 4)
}

module "vpc" {
  source          = "../../modules/vpc"
  infra_env       = var.infra_env
  vpc_cidr        = "10.0.0.0/17"
  azs             = ["us-east-1a", "us-east-1b", "us-east-1c"]
  public_subnets  = slice(local.cider_subnets, 0, 3)
  private_subnets = slice(local.cider_subnets, 3, 6)
}
