resource "google_project" "root" {
  name       = var.root_project_name
  project_id = var.root_project_id
  folder_id  = var.folder_id
}

resource "google_project_service" "root_iam" {
  project = google_project.root.project_id
  service = "iam.googleapis.com"

  disable_dependent_services = true
}

resource "google_folder" "folder" {
  count        = length(var.folders)
  display_name = var.folders[count.index].display_name
  parent       = "folders/${var.folder_id}"
}

locals {
  all_folder_attributes = [
  for folder in google_folder.folder[*] :
  {
    id           = folder.folder_id,
    display_name = folder.display_name
  }
  ]
}

resource "google_project" "project" {
  count = length(var.projects)

  name       = var.projects[count.index].name
  project_id = var.projects[count.index].id

  folder_id = [for folder in local.all_folder_attributes : folder.id if folder.display_name == var.projects[count.index].folder][0]
}

locals {
  all_project_attributes = [
  for project in google_project.project[*] :
  {
    id        = project.project_id,
    name      = project.name
    folder_id = project.folder_id
  }
  ]
}
