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

data "aws_ami" "proxy" {
  most_recent = true

  filter {
    name   = "state"
    values = ["available"]
  }

  filter {
    name   = "tag:Component"
    values = ["proxy"]
  }

  filter {
    name   = "tag:Project"
    values = ["caddy-proxy"]
  }

  filter {
    name   = "tag:Environment"
    values = [var.infra_env]
  }

  filter {
    name   = "tag:Role"
    values = ["baked-ami"]
  }

  owners = ["self"]

}

data "aws_vpc" "vpc" {
  tags = {
    "Name"        = "caddy-vpc-${var.infra_env}"
    "Environment" = var.infra_env
    "Project"     = "caddy-proxy",
    "ManagedBy"   = "terraform",
  }
}

data "aws_subnets" "public_subnets" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.vpc.id]
  }

  tags = {
    "Name"        = "caddy-public-subnet-${var.infra_env}"
    "Environment" = var.infra_env
    "Project"     = "caddy-proxy",
    "ManagedBy"   = "terraform",
    "Role"        = "public"
  }
}

data "aws_subnets" "private_subnets" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.vpc.id]
  }

  tags = {
    "Name"        = "caddy-private-subnet-${var.infra_env}"
    "Environment" = var.infra_env
    "Project"     = "caddy-proxy",
    "ManagedBy"   = "terraform",
    "Role"        = "private"
  }
}

data "aws_security_groups" "public_sg" {
  tags = {
    "Name"        = "caddy-public-sg-${var.infra_env}",
    "Environment" = var.infra_env
    "Project"     = "caddy-proxy",
    "ManagedBy"   = "terraform",
  }
}

data "aws_security_groups" "private_sg" {
  tags = {
    "Name"        = "caddy-private-sg-${var.infra_env}",
    "Environment" = var.infra_env
    "Project"     = "caddy-proxy",
    "ManagedBy"   = "terraform",
  }
}

module "autoscale_proxy" {
  source                = "../../modules/ec2"
  instance_ami          = data.aws_ami.proxy.id
  infra_env             = var.infra_env
  instance_size         = "t3a.medium"
  infra_role            = "proxy"
  security_groups       = data.aws_security_groups.public_sg.ids
  asg_subnets           = data.aws_subnets.public_subnets.ids
  nlb_subnets           = data.aws_subnets.public_subnets.ids
  vpc_id                = data.aws_vpc.vpc.id
  asg_max_instances     = 4
  asg_desired_instances = 2

  instance_tags = {
    "Name" = "caddy-proxy-${var.infra_env}",
  }
}
