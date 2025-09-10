include "root" { path = find_in_parent_folders("terragrunt.hcl") }
include "env"  { path = find_in_parent_folders("_env/env.hcl") }
terraform { source = local.tf.web }
inputs = {
  name = local.name_prefix
  tags = merge(local.default_tags, local.env_tags)
}