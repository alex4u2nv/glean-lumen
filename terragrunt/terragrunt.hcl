terraform_version_constraint = ">= 1.6.0"
locals {
  terraform_repo = "git::https://github.com/alex4u2nv/glean-lumen.git"
  terraform_ref  = "main"

  s3_bucket      = "tg-state-503876631416-us-east-2"
  dynamodb_table = "terragrunt-locks-503876631416"
  aws_region     = "us-east-2"

  default_tags = {
    project      = "gptanalysis"
    owner        = "platform"
    cost_center  = "0000"
    managed_by   = "terragrunt"
    account_id   = "503876631416"
  }
}

remote_state {
  backend = "s3"
  generate = {
    path      = "backend.tf"
    if_exists = "overwrite"
  }
  config = {
    bucket         = local.s3_bucket
    key            = "${path_relative_to_include()}/terraform.tfstate"
    region         = local.aws_region
    encrypt        = true
    dynamodb_table = local.dynamodb_table
  }
  tf = {
    cognito  = "${local.terraform_repo}//modules/cognito?ref=${local.terraform_ref}"
    lambda   = "${local.terraform_repo}//modules/lambda?ref=${local.terraform_ref}"
    api      = "${local.terraform_repo}//modules/api?ref=${local.terraform_ref}"
    web      = "${local.terraform_repo}//modules/webhosting?ref=${local.terraform_ref}"
  }
}

generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite"
  contents  = <<EOF
terraform {
  required_version = ">= 1.6.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    archive = {
      source  = "hashicorp/archive"
      version = "~> 2.4"
    }
  }
}

# Default provider (Sandbox account / primary region)
provider "aws" {
  region = "${local.aws_region}"
  default_tags {
    tags = {
      project     = "gptanalysis"
      owner       = "platform"
      cost_center = "0000"
      managed_by  = "terragrunt"
      account_id  = "${local.default_tags.account_id}"
    }
  }
}

# us-east-1 alias (for CloudFront ACM certificates, etc.)
provider "aws" {
  alias  = "us_east_1"
  region = "us-east-1"
  default_tags {
    tags = {
      project     = "glean"
      owner       = "platform"
      cost_center = "0000"
      managed_by  = "terragrunt"
      account_id  = "${local.default_tags.account_id}"
    }
  }
}

# Cross-account Route53 writer in Billing account via named profile
# Configure the local ~/.aws/config profile named "billing-r53" to assume the billing role
provider "aws" {
  alias   = "billing_r53"
  region  = "us-east-1"
  profile = "billing-r53"
}
EOF
}

