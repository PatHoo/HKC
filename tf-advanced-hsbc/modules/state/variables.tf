variable "project_id" {
  description = "The GCP project ID"
  type        = string
}

variable "region" {
  description = "The GCP region where the state bucket will be created"
  type        = string
  default     = "asia-east1"
}

variable "service_account_id" {
  description = "The service account ID that will have access to the state bucket"
  type        = string
  default     = "terraform"
}
