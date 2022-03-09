output "dynamodb_arn" {
  value = aws_dynamodb_table.caddy-ssl-certificates.arn
}

output "iam_dynamo_db_user" {
  value = aws_iam_user.dynamodb-user
}

output "secrets" {
  value = aws_secretsmanager_secret.secrets
}
