variable "name" {
  type = string
}
variable "handler" {
  type = string
}
variable "runtime" {
  type    = string
  default = "python3.12"
}
variable "timeout" {
  type    = number
  default = 10
}
variable "memory_size" {
  type    = number
  default = 256
}
variable "env" {
  type = map(string)
  default = {}
}
variable "tags" {
  type = map(string)
  default = {}
}
variable "prefix" {
  type = string
}
variable "lambda_logging_level" {
  type = string
}

variable "client_key_secret_name" {
  type        = string
}

variable "index_key_secret_name" {
  type        = string
}

locals {
  lambda_root = "${path.module}/lambda/src"
}

data "aws_secretsmanager_secret" "client_key" {
  name = var.client_key_secret_name
}

data "aws_secretsmanager_secret" "index_key" {
  name = var.index_key_secret_name
}