resource "aws_globalaccelerator_accelerator" "this" {
  name            = "caddy-ga-${var.infra_env}"
  ip_address_type = "IPV4"
  enabled         = true

  tags = {
    "Name"        = "caddy-ga-${var.infra_env}",
    "Environment" = var.infra_env
    "Project"     = "caddy-proxy",
    "ManagedBy"   = "terraform",
  }
}

resource "aws_globalaccelerator_listener" "http" {
  accelerator_arn = aws_globalaccelerator_accelerator.this.id
  client_affinity = "NONE"
  protocol        = "TCP"
  port_range {
    from_port = 80
    to_port   = 80
  }
}

resource "aws_globalaccelerator_endpoint_group" "http" {
  listener_arn = aws_globalaccelerator_listener.http.id
  endpoint_configuration {
    endpoint_id = aws_lb.nlb.arn
    weight      = 100
  }
}

resource "aws_globalaccelerator_listener" "https" {
  accelerator_arn = aws_globalaccelerator_accelerator.this.id
  client_affinity = "NONE"
  protocol        = "TCP"
  port_range {
    from_port = 443
    to_port   = 443
  }
}


resource "aws_globalaccelerator_endpoint_group" "https" {
  listener_arn = aws_globalaccelerator_listener.https.id
  endpoint_configuration {
    endpoint_id = aws_lb.nlb.arn
    weight      = 100
  }
}
