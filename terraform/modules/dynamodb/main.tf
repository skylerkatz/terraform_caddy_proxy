resource "aws_dynamodb_table" "caddy-ssl-certificates" {
  name         = "caddy_proxy_ssl_certificates_${var.infra_env}"
  hash_key     = "PrimaryKey"
  billing_mode = "PAY_PER_REQUEST"
  point_in_time_recovery {
    enabled = true
  }

  attribute {
    name = "PrimaryKey"
    type = "S"
  }
  tags = {
    "Name"        = "caddy-caddy-ssl-certificates-${var.infra_env}",
    "Environment" = var.infra_env
    "Project"     = "caddy-proxy",
    "ManagedBy"   = "terraform",
  }
}
