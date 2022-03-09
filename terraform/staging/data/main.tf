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

module "ssl_certificate_store" {
  source    = "../../modules/dynamodb"
  infra_env = var.infra_env
}
