data "terraform_remote_state" "prerequisites" {
  backend = "local"

  config = {
    path = "${path.module}/../../../../state/prerequisites.tfstate"
  }
}

module "project_hierarchy" {
  source = "./../../../../"

  folder_id = var.folder_id

  root_project_name = var.root_project_name
  root_project_id   = var.root_project_id

  folders = var.folders

  projects = var.projects
}
