resource "aws_iam_user" "dynamodb-user" {
  name = "caddy-dynamo-db-${var.infra_env}"
  tags = {
    "Name"        = "caddy-dynamo-db-${var.infra_env}",
    "Environment" = var.infra_env
    "Project"     = "caddy-proxy",
    "ManagedBy"   = "terraform",
  }
}
resource "aws_iam_policy" "dynamodb" {
  name        = "caddy-dynamo-db-${var.infra_env}"
  description = "The Policy used by Caddy to access Dynamo DB for SSL"
  path        = "/"
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Sid" : "VisualEditor0",
        "Effect" : "Allow",
        "Action" : [
          "dynamodb:PutItem",
          "dynamodb:DeleteItem",
          "dynamodb:GetItem",
          "dynamodb:Scan"
        ],
        "Resource" : aws_dynamodb_table.caddy-ssl-certificates.arn
      }
    ]
  })
  tags = {
    "Name"        = "caddy-dynamo-db-${var.infra_env}",
    "Environment" = var.infra_env
    "Project"     = "caddy-proxy",
    "ManagedBy"   = "terraform",
  }
}

resource "aws_iam_user_policy_attachment" "dynamo-db-attachment" {
  user       = aws_iam_user.dynamodb-user.name
  policy_arn = aws_iam_policy.dynamodb.arn
}

resource "aws_iam_access_key" "dynamo-db-user-access-key" {
  user = aws_iam_user.dynamodb-user.name
}

resource "aws_secretsmanager_secret" "secrets" {
  name        = "caddy/secrets-${var.infra_env}"
  description = "Secrets used by the Your.Bible infrastructure"
  tags = {
    "Name"        = "caddy-secrets-${var.infra_env}",
    "Environment" = var.infra_env
    "Project"     = "caddy-proxy",
    "ManagedBy"   = "terraform",
  }
}

resource "aws_secretsmanager_secret_version" "iam-secrets" {
  secret_id = aws_secretsmanager_secret.secrets.id
  secret_string = jsonencode({
    dynamo_db_aws_access_key        = aws_iam_access_key.dynamo-db-user-access-key.id
    dynamo_db_aws_secret_access_key = aws_iam_access_key.dynamo-db-user-access-key.secret
    }
  )
}
