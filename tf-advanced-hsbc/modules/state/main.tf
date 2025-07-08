# GCS Bucket for Terraform State
resource "google_storage_bucket" "terraform_state" {
  name          = "${var.project_id}-tfstate"
  location      = var.region
  force_destroy = false
  versioning {
    enabled = true
  }
  lifecycle_rule {
    action {
      type = "Delete"
    }
    condition {
      num_newer_versions = 5
    }
  }
}

# IAM Policy for State Bucket
resource "google_storage_bucket_iam_member" "state_iam" {
  bucket = google_storage_bucket.terraform_state.name
  role   = "roles/storage.admin"
  member = "serviceAccount:${data.google_service_account.terraform.email}"
}

data "google_service_account" "terraform" {
  account_id = var.service_account_id
  project    = var.project_id
}
