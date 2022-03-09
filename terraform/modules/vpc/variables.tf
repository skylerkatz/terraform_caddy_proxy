variable "infra_env" {
  type        = string
  description = "Infrastructure Environment"
}

variable "vpc_cidr" {
  type        = string
  description = "The IP range to use for the VPC"
  default     = "10.0.0.0/16"
}

variable "azs" {
  type        = list(string)
  description = "Availability Zones to create subnets into"
}

variable "public_subnets" {
  type        = list(string)
  description = "Subnets to create for public network traffic, one per AZ"
}

variable "private_subnets" {
  type        = list(string)
  description = "Subnets to create for private network traffic, one per AZ"
}

