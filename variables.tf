variable "root_project_id" {
  type = string
}

variable "root_project_name" {
  type = string
}

variable "folder_id" {
  description = "The ID of the folder which to create the hierarchy in. (Optional)"
  type        = number
  default     = null
}

variable "folders" {
  description = "The list of folders to organize projects in. Defaults to an empty list."
  type        = list(object({
    display_name = string,
  }))
  default = []
}

variable "projects" {
  description = "The list of projects to create. Defaults to an empty list."
  type        = list(object({
    name   = string,
    id     = string,
    folder = string
  }))
  default = []
}
