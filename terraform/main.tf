provider "google" {
  project = var.project_id
  region  = var.region
}

# 1. Store the GitHub Token in Secret Manager (Required for the connection)
resource "google_secret_manager_secret" "github_token" {
  secret_id = "github-token"

  replication {
    user_managed {
      # This is the "proper" way to do automatic replication in newer versions
      # or simply use the 'automatic = true' if using an older provider version.
      replicas {
        location = "us-central1"
      }
    }
  }
}

resource "google_secret_manager_secret_version" "github_token_version" {
  secret      = google_secret_manager_secret.github_token.id
  secret_data = var.github_pat
}

# 2. Create the Connection
resource "google_cloudbuildv2_connection" "my_connection" {
  location = var.region
  name     = "github-connection"

  github_config {
    # Using a PAT allows for more programmatic setup than the GitHub App
    authorizer_credential {
      oauth_token_secret_version = google_secret_manager_secret_version.github_token_version.id
    }
  }
  depends_on = [google_secret_manager_secret_iam_member.cb_sa_secret_access]
}

# 3. Link the Repository
resource "google_cloudbuildv2_repository" "my_repo" {
  location          = var.region
  name              = var.repo_name
  parent_connection = google_cloudbuildv2_connection.my_connection.name
  remote_uri        = "https://github.com/${var.github_owner}/${var.repo_name}.git"
}

# 4. Create the Folder-Based Triggers
resource "google_cloudbuild_trigger" "folder_triggers" {
  for_each = toset(var.agent_patterns)

  name     = "trigger-${each.value}"
  location = var.region

  repository_event_config {
    repository = google_cloudbuildv2_repository.my_repo.id
    #push { branch = "^main$" }
    push { branch = "^(main|ld)$" }
  }

  included_files = ["agent-patterns/${each.value}/**"]
  filename       = "agent_patterns/${each.value}/cloudbuild.yaml"
}

# Get the project number (needed to identify the Service Agent)
data "google_project" "project" {}

# Grant the Cloud Build Service Agent access to the GitHub token
resource "google_secret_manager_secret_iam_member" "cb_sa_secret_access" {
  project   = data.google_project.project.project_id
  secret_id = google_secret_manager_secret.github_token.id
  role      = "roles/secretmanager.secretAccessor"

  # This is the standard format for the Cloud Build Service Agent
  member = "serviceAccount:service-${data.google_project.project.number}@gcp-sa-cloudbuild.iam.gserviceaccount.com"

  # Ensure the secret version exists before trying to grant access
  depends_on = [google_secret_manager_secret_version.github_token_version]
}
