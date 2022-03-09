module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "3.11.0"

  name = "caddy-vpc-${var.infra_env}"
  cidr = var.vpc_cidr

  azs = var.azs

  # Single NAT Gateway
  enable_nat_gateway     = true
  single_nat_gateway     = true
  one_nat_gateway_per_az = false

  private_subnets = var.private_subnets
  public_subnets  = var.public_subnets

  private_subnet_tags = {
    "Name" = "caddy-private-subnet-${var.infra_env}"
    "Role" = "private"
  }

  public_subnet_tags = {
    "Name" = "caddy-public-subnet-${var.infra_env}"
    "Role" = "public"
  }

  public_route_table_tags = {
    "Name" = "caddy-public-route-table-${var.infra_env}"
  }

  private_route_table_tags = {
    "Name" = "caddy-private-route-table-${var.infra_env}"
  }

  nat_gateway_tags = {
    "Name" = "caddy-ngw-${var.infra_env}"
  }

  nat_eip_tags = {
    "Name" = "caddy-ngw-eip-${var.infra_env}"
  }

  igw_tags = {
    "Name" = "caddy-igw-${var.infra_env}"
  }

  vpc_tags = {
    "Name" = "caddy-vpc-${var.infra_env}",
  }

  tags = {
    "Name"        = "caddy-${var.infra_env}"
    "Environment" = var.infra_env
    "Project"     = "caddy-proxy",
    "ManagedBy"   = "terraform",
  }
}
