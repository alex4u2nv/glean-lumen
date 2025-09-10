variable "name"             { type = string }
variable "lambda_invoke_arn"{ type = string }
variable "lambda_name"      { type = string } # for permission
variable "cognito_pool_arn" { type = string }
variable "stage_name"       { type = string  default = "Prod" }
variable "path"             { type = string  default = "finload" }
variable "method"           { type = string  default = "GET" }
variable "tags"             { type = map(string) default = {} }
