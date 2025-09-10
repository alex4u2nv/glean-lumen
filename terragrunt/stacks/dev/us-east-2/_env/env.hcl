locals {
  env          = "dev"
  region       = "us-east-2"
  name_prefix  = "glean"
  env_tags = {
    environment = "dev"
  }
  callback_urls = ["http://localhost:3000/callback"]
  logout_urls   = ["http://localhost:3000/logout"]
}