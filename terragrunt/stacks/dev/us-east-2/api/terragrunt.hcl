include "root" { path = find_in_parent_folders("terragrunt.hcl") }
include "env"  { path = find_in_parent_folders("_env/env.hcl") }
terraform { source = local.tf.api }

dependency "cognito"        { config_path = "../cognito" }
dependency "glean" { config_path = "../glean" }

inputs = {
  name              = "${local.name_prefix}-api"
  lambda_invoke_arn = dependency.lambda_finload.outputs.invoke_arn
  lambda_name       = dependency.lambda_finload.outputs.function_name
  cognito_pool_arn  = dependency.cognito.outputs.user_pool_arn
  stage_name        = "Prod"
  path              = "glean"
  method            = "GET"
  tags              = merge(local.default_tags, local.env_tags)
}