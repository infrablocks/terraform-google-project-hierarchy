locals {
  root_project_id   = "${var.component}-${var.deployment_identifier}-root"
  root_project_name = "${var.component}-${var.deployment_identifier}-root"
  management_project_id     = "${var.component}-${var.deployment_identifier}-mgmt"
  management_project_name   = "${var.component}-${var.deployment_identifier}-mgmt"
}
resource "google_project" "root" {
  name       = local.root_project_name
  project_id = local.root_project_id
  folder_id  = var.folder_id
}

resource "google_folder" "management_folder" {
  display_name = "management"
  parent = "folders/${var.folder_id}"
}

resource "google_project" "management" {
  name       = local.management_project_name
  project_id = local.management_project_id
  folder_id  = google_folder.management_folder.folder_id
}

resource "google_project_service" "root_iam" {
  project = google_project.root.project_id
  service = "iam.googleapis.com"

  disable_dependent_services = true
}
