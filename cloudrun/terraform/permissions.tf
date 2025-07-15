# This Terraform code grants the necessary permissions to the default
# Cloud Build service account to deploy applications to Cloud Run.

# ------------------------------------------------------------------------------
# Provider Configuration
# ------------------------------------------------------------------------------
terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 4.50.0"
    }
  }
}

variable "project_id" {
  description = "The Google Cloud project ID where permissions will be applied."
  type        = string
}

# Get the current project's details to find the project number.
data "google_project" "project" {
  project_id = var.project_id
}

# Define the roles needed by the Cloud Build service account
locals {
  cloud_build_service_account = "${data.google_project.project.number}@cloudbuild.gserviceaccount.com"
  required_roles = [
    "roles/run.admin",              # For deploying and managing Cloud Run services
    "roles/iam.serviceAccountUser", # To act as the Cloud Run runtime service account
    "roles/artifactregistry.admin"  # To create and manage Artifact Registry repositories
  ]
}

# Grant each required role to the Cloud Build service account
resource "google_project_iam_member" "cloud_build_permissions" {
  for_each = toset(local.required_roles)

  project = data.google_project.project.project_id
  role    = each.key
  member  = "serviceAccount:${local.cloud_build_service_account}"
}
