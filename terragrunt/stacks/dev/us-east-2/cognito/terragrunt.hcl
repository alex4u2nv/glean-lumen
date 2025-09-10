include "root" { path = find_in_parent_folders("terragrunt.hcl") }
include "env"  { path = find_in_parent_folders("_env/env.hcl") }
terraform { source = local.tf.cognito }
inputs = {
  name          = local.name_prefix
  callback_urls = local.callback_urls
  logout_urls   = local.logout_urls
  tags          = merge(local.default_tags, local.env_tags)
}