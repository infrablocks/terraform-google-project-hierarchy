module "project_hierarchy" {
  source = "./../../"

  folder_id = var.folder_id

  root_project_name = var.root_project_name
  root_project_id   = var.root_project_id

  folders = [
    {
      display_name: "development"
    },
    {
      display_name: "production"
    },
  ]

  projects = [
    {
      name: "development-${var.deployment_identifier}",
      id: "development-${var.deployment_identifier}",
      folder: "development"
    },
    {
      name: "production-${var.deployment_identifier}",
      id: "production-${var.deployment_identifier}",
      folder: "production"
    }
  ]
}
