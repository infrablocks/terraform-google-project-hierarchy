data "terraform_remote_state" "prerequisites" {
  backend = "local"

  config = {
    path = "${path.module}/../../../../state/prerequisites.tfstate"
  }
}

module "project_hierarchy" {
  # This makes absolutely no sense. I think there's a bug in terraform.
  source = "./../../../../../../../"

  folder_id             = var.folder_id

  root_project_name = var.root_project_name
  root_project_id = var.root_project_id

  folders = [
    {
      display_name : "management"
    },
    {
      display_name : "production"
    },
  ]

  projects = [
    {
      name : var.management_project_name,
      id : var.management_project_id,
      folder : "management"
    },
    {
      name : var.production_project_name,
      id : var.production_project_id,
      folder : "production"
    },
  ]
}
