variable "region" {}

variable "component" {}
variable "deployment_identifier" {}

variable "backend" {
  default = null
}

variable "role_name" {
  default = null
}
variable "role_name_prefix" {
  default = null
}

variable "bind_secret_id" {
  default = null
}

variable "secret_id_bound_cidrs" {
  type    = list(string)
  default = null
}
variable "secret_id_num_uses" {
  type    = number
  default = null
}
variable "secret_id_ttl" {
  type    = number
  default = null
}

variable "token_ttl" {
  type    = number
  default = null
}
variable "token_max_ttl" {
  type    = number
  default = null
}
variable "token_period" {
  type    = number
  default = null
}
variable "token_policies" {
  type = list(string)
  default = null
}
variable "token_bound_cidrs" {
  default = null
  type    = list(string)
}
variable "token_explicit_max_ttl" {
  type    = number
  default = null
}
variable "token_num_uses" {
  type    = number
  default = null
}
variable "token_type" {
  default = null
}

variable "default_secret_id_cidr_list" {
  type    = list(string)
  default = null
}