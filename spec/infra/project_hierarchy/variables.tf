variable "region" {}

variable "component" {}

variable "deployment_identifier" {}

variable "folder_id" {
  type = number
}

variable "backend" {
  default = null
}
