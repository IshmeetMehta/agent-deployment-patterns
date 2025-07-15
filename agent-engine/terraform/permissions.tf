# This Terraform configuration grants the necessary IAM roles to the default
# Cloud Build service account to deploy and test agents on Vertex AI Agent Engine.

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

# ------------------------------------------------------------------------------
# IAM Bindings for Cloud Build Service Account
# ------------------------------------------------------------------------------

# Get the current project's details to find the project number.
data "google_project" "project" {}

# Define the roles needed by the Cloud Build service account based on README.md.
locals {
  cloud_build_service_account = "${data.google_project.project.number}@cloudbuild.gserviceaccount.com"
  required_roles = toset([
    "roles/aiplatform.user",    # To deploy and interact with Vertex AI agents.
    "roles/storage.admin",      # To write artifacts to the GCS staging bucket.
    "roles/iam.serviceAccountUser" # To act as other service accounts if needed.
  ])
}

# Grant each required role to the Cloud Build service account.
resource "google_project_iam_member" "cloud_build_agent_engine_permissions" {
  for_each = local.required_roles

  project = data.google_project.project.project_id
  role    = each.key
  member  = "serviceAccount:${local.cloud_build_service_account}"
}

# ------------------------------------------------------------------------------
# IAM Bindings for Agent Runtime Service Account
# ------------------------------------------------------------------------------

# The agent, when deployed, runs under a service account. By default, this is
# the Compute Engine default service account. This service account needs
# permission to call the underlying LLM (e.g., Gemini). Granting the
# "Vertex AI User" role provides this permission.
resource "google_project_iam_member" "agent_runtime_permissions" {
  project = data.google_project.project.project_id
  role    = "roles/aiplatform.user"
  member  = "serviceAccount:${data.google_project.project.number}-compute@developer.gserviceaccount.com"
}