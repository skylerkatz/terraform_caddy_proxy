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
  default     = "staging"
}

module "vpc" {
  source          = "../../modules/vpc"
  infra_env       = var.infra_env
  vpc_cidr        = "10.0.0.0/17"
  azs             = ["us-east-1a", "us-east-1b"]
  public_subnets  = slice(cidrsubnets("10.0.0.0/17", 4, 4, 4, 4), 0, 2)
  private_subnets = slice(cidrsubnets("10.0.0.0/17", 4, 4, 4, 4), 2, 4)
}
