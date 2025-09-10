variable "name" { type = string }
variable "default_root_object" { type = string default = "index.html" }
variable "tags" { type = map(string) default = {} }
