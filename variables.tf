variable "component" {
  description = "The component for which this approle exists."
  type        = string
}
variable "deployment_identifier" {
  type        = string
  description = "An identifier for this instantiation."
}

variable "folder_id" {
  type = number
  description = "The ID of the folder which to create the hierarchy in. (Optional)"
  default = null
}

variable "folders" {
  type = list(object({
    display_name = string,
  }))
  default = []
  description = "The list of folders to organize projects in. Defaults to an empty list."
}

variable "projects" {
  type = list(object({
    name = string,
    folder = string
  }))
  default = []
  description = "The list of projects to create. Defaults to an empty list."
}
