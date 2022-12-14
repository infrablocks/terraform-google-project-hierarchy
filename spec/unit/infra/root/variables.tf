variable "component" {}
variable "deployment_identifier" {}

variable "folder_id" {
  type = number
}

variable "root_project_name" {
  type = string
}

variable "root_project_id" {
  type = string
}

variable "folders" {
  type        = list(object({
    display_name = string,
  }))
  default = null
}

variable "projects" {
  type        = list(object({
    name   = string,
    id     = string,
    folder = string
  }))
  default = null
}
