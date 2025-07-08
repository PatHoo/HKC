output "bucket_name" {
  description = "The name of the created GCS bucket for Terraform state"
  value       = google_storage_bucket.terraform_state.name
}

output "bucket_location" {
  description = "The location of the created GCS bucket"
  value       = google_storage_bucket.terraform_state.location
}

output "bucket_self_link" {
  description = "The URI of the created GCS bucket"
  value       = google_storage_bucket.terraform_state.self_link
}
