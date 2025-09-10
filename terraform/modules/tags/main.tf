

locals {
  base = {
    project     = var.project
    environment = var.environment
    owner       = var.owner
    cost_center = var.cost_center
    managed_by  = "terragrunt"
  }
  tags = merge(local.base, var.customer == null ? {} : { customer = var.customer }, var.extra)
}

