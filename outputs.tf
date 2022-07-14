output "management_folder_id" {
  value = google_folder.management_folder.folder_id
}

output "management_project_id" {
  value = google_project.management.project_id
}

output "management_service_account_id" {
  value = google_service_account.service_account.account_id
}
