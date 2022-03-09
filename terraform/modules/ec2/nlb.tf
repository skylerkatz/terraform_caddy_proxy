resource "aws_lb" "nlb" {
  name               = "caddy-nlb-${var.infra_env}"
  internal           = false
  load_balancer_type = "network"
  subnets            = var.nlb_subnets
  ip_address_type    = "ipv4"

  tags = {
    "Name"        = "caddy-nlb-${var.infra_env}"
    "Environment" = var.infra_env
    "Project"     = "caddy-proxy",
    "ManagedBy"   = "terraform",
  }
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.nlb.arn
  port              = "80"
  protocol          = "TCP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.http.arn
  }

  tags = {
    "Name"        = "caddy-listener-http-${var.infra_env}"
    "Environment" = var.infra_env
    "Project"     = "caddy-proxy",
    "ManagedBy"   = "terraform",
  }
}

resource "aws_lb_listener" "https" {
  load_balancer_arn = aws_lb.nlb.arn
  port              = "443"
  protocol          = "TCP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.https.arn
  }

  tags = {
    "Name"        = "caddy-listener-https-${var.infra_env}"
    "Environment" = var.infra_env
    "Project"     = "caddy-proxy",
    "ManagedBy"   = "terraform",
  }
}

resource "aws_lb_target_group" "http" {
  name                 = "caddy-tg-http-${var.infra_env}"
  port                 = 80
  protocol             = "TCP"
  vpc_id               = var.vpc_id
  deregistration_delay = 30
  health_check {
    interval = 10
    path     = "/health"
    port     = "80"
  }

  tags = {
    "Name"        = "caddy-tg-http-${var.infra_env}"
    "Environment" = var.infra_env
    "Project"     = "caddy-proxy",
    "ManagedBy"   = "terraform",
  }
}

resource "aws_lb_target_group" "https" {
  name                 = "caddy-tg-https-${var.infra_env}"
  port                 = 443
  protocol             = "TCP"
  vpc_id               = var.vpc_id
  deregistration_delay = 30
  health_check {
    interval = 10
    path     = "/health"
    port     = "80"
  }

  tags = {
    "Name"        = "caddy-tg-https-${var.infra_env}"
    "Environment" = var.infra_env
    "Project"     = "caddy-proxy",
    "ManagedBy"   = "terraform",
  }
}
