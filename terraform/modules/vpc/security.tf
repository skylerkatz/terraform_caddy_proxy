###
# Public Security Group
###

resource "aws_security_group" "public" {
  name        = "caddy-public-sg-${var.infra_env}"
  description = "Public internet access"
  vpc_id      = module.vpc.vpc_id

  tags = {
    "Name"        = "caddy-public-sg-${var.infra_env}",
    "Environment" = var.infra_env
    "Project"     = "caddy-proxy",
    "ManagedBy"   = "terraform",
  }
}

resource "aws_security_group_rule" "public_out" {
  type        = "egress"
  from_port   = 0
  to_port     = 0
  protocol    = "-1"
  cidr_blocks = ["0.0.0.0/0"]

  security_group_id = aws_security_group.public.id
}

resource "aws_security_group_rule" "public_in_ssh" {
  type        = "ingress"
  from_port   = 22
  to_port     = 22
  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"]

  security_group_id = aws_security_group.public.id
}

resource "aws_security_group_rule" "public_in_http" {
  type        = "ingress"
  from_port   = 80
  to_port     = 80
  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"]

  security_group_id = aws_security_group.public.id
}

resource "aws_security_group_rule" "public_in_https" {
  type             = "ingress"
  from_port        = 443
  to_port          = 443
  protocol         = "tcp"
  cidr_blocks      = ["0.0.0.0/0"]
  ipv6_cidr_blocks = ["::/0"]

  security_group_id = aws_security_group.public.id
}

###
# Private Security Group
###

resource "aws_security_group" "private" {
  name        = "caddy-private-sg-${var.infra_env}"
  description = "Private internet access"
  vpc_id      = module.vpc.vpc_id

  tags = {
    "Name"        = "caddy-private-sg-${var.infra_env}",
    "Environment" = var.infra_env
    "Project"     = "caddy-proxy",
    "ManagedBy"   = "terraform",
  }
}

resource "aws_security_group_rule" "private_out" {
  type        = "egress"
  from_port   = 0
  to_port     = 0
  protocol    = "-1"
  cidr_blocks = ["0.0.0.0/0"]

  security_group_id = aws_security_group.private.id
}

resource "aws_security_group_rule" "private_in_sg" {
  type                     = "ingress"
  from_port                = 0
  to_port                  = 65535
  protocol                 = "-1"
  source_security_group_id = aws_security_group.public.id

  security_group_id = aws_security_group.private.id
}

resource "aws_security_group_rule" "private_in_vpc" {
  type        = "ingress"
  from_port   = 0
  to_port     = 65535
  protocol    = "-1"
  cidr_blocks = [module.vpc.vpc_cidr_block]

  security_group_id = aws_security_group.private.id
}
