
data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

resource "aws_cognito_user_pool" "this" {
  name                  = "${var.name}-userpool"
  username_attributes   = ["email"]
  auto_verified_attributes = ["email"]

  password_policy {
    minimum_length  = 8
    require_lowercase = true
    require_numbers   = true
    require_symbols   = false
    require_uppercase = true
  }

  tags = var.tags
}

resource "aws_cognito_user_pool_client" "this" {
  name         = "${var.name}-app-client"
  user_pool_id = aws_cognito_user_pool.this.id
  allowed_oauth_flows                   = ["code"]
  allowed_oauth_scopes                  = ["email", "openid", "profile"]
  allowed_oauth_flows_user_pool_client  = true
  generate_secret                       = false
  callback_urls                         = var.callback_urls
  logout_urls                           = var.logout_urls
  supported_identity_providers          = ["COGNITO"]
  prevent_user_existence_errors         = "ENABLED"

  tags = var.tags
}

resource "aws_cognito_user_pool_domain" "this" {
  domain       = replace(lower("${var.name}-${data.aws_caller_identity.current.account_id}-${data.aws_region.current.name}-app"), "/[^a-z0-9-]/", "-")
  user_pool_id = aws_cognito_user_pool.this.id
}
