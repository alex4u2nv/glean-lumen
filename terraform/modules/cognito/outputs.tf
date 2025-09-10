
output "user_pool_arn"       { value = aws_cognito_user_pool.this.arn }
output "user_pool_id"        { value = aws_cognito_user_pool.this.id }
output "user_pool_client_id" { value = aws_cognito_user_pool_client.this.id }
output "cognito_domain_url"  { value = "https://${aws_cognito_user_pool_domain.this.domain}.auth.${data.aws_region.current.name}.amazoncognito.com" }