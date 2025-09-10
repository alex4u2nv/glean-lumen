variable "project"     { type = string }
variable "environment" { type = string }
variable "owner"       { type = string }
variable "cost_center" { type = string }
variable "customer"    { type = string  default = null }
variable "extra"       { type = map(string) default = {} }