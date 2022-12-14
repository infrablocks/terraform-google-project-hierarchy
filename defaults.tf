locals {
  # default for cases when `null` value provided, meaning "use default"
  folders  = var.folders == null ? [] : var.folders
  projects = var.projects == null ? [] : var.projects
}