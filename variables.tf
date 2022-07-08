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
