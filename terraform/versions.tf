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

# Default provider (Sandbox region)
provider "aws" {
  region  = "us-east-2"
  profile = "sandbox"
}

# For CloudFront ACM certs (must be in us-east-1)
provider "aws" {
  alias   = "us_east_1"
  region  = "us-east-1"
  profile = "sandbox"
}

# For parent hosted zone in billing account
provider "aws" {
  alias   = "billing_r53"
  region  = "us-east-1"    # Route53 is global
  profile = "billing-r53"
}