include "root" { path = find_in_parent_folders("terragrunt.hcl") }
include "env"  { path = find_in_parent_folders("_env/env.hcl") }
terraform { source = local.tf.glean }
inputs = {
  name       = "${local.name_prefix}-glean"
  handler    = "app.lambda_handler"
  runtime    = "python3.12"
  env        = {}
  tags       = merge(local.default_tags, local.env_tags)
}