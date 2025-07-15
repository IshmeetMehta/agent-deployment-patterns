# ------------------------------------------------------------------------------
# Provider Configuration
#
# This configuration assumes you are running Terraform locally and have
# authenticated using Google Cloud Application Default Credentials (ADC).
# To set this up, run:
# gcloud auth application-default login
#
# The provider will automatically use these credentials.
# ------------------------------------------------------------------------------
terraform {
  required_version = ">= 1.0"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 4.50.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.11"
    }
  }
}

# ------------------------------------------------------------------------------
# Input Variables
# ------------------------------------------------------------------------------

variable "project_id" {
  description = "The Google Cloud project ID to deploy resources into."
  type        = string
}

variable "region" {
  description = "The Google Cloud region to deploy resources into."
  type        = string
  default     = "us-central1"
}

variable "cluster_name" {
  description = "The name for the GKE cluster."
  type        = string
  default     = "agent-deployment-cluster"
}

variable "network_name" {
  description = "The name of the VPC network."
  type        = string
  default     = "agent-deployment-vpc"
}

variable "subnet_name" {
  description = "The name of the subnet."
  type        = string
  default     = "gke-subnet"
}

variable "gsa_name" {
  description = "The name for the Google Service Account used by the agent."
  type        = string
  default     = "agent-gsa"
}

variable "ksa_name" {
  description = "The name of the Kubernetes Service Account. Must match the name in deployment.yaml."
  type        = string
  default     = "agent-ksa"
}

variable "ar_repo_name" {
  description = "The name for the Artifact Registry repository. Must match _AR_REPO_NAME in cloudbuild.yaml."
  type        = string
  default     = "agent-images"
}

# ------------------------------------------------------------------------------
# Core Resources
# ------------------------------------------------------------------------------

# Enable the Service Usage API first, as it's needed to manage other services.
resource "google_project_service" "service_usage" {
  project            = var.project_id
  service            = "serviceusage.googleapis.com"
  disable_on_destroy = false
}

# Enable the GKE API
resource "google_project_service" "gke_api" {
  project            = var.project_id
  service            = "container.googleapis.com"
  disable_on_destroy = false # Keep API enabled even after cluster is destroyed

  # Ensure the Service Usage API is enabled before trying to enable this one.
  depends_on = [google_project_service.service_usage]
}

# Create a VPC Network for the GKE cluster
resource "google_compute_network" "vpc" {
  project                 = var.project_id
  name                    = var.network_name
  auto_create_subnetworks = false
}

# Create a Subnet for the GKE cluster
resource "google_compute_subnetwork" "subnet" {
  project                  = var.project_id
  name                     = var.subnet_name
  ip_cidr_range            = "10.10.0.0/20"
  region                   = var.region
  network                  = google_compute_network.vpc.id
  private_ip_google_access = true

  secondary_ip_range {
    range_name    = "gke-pods-range"
    ip_cidr_range = "10.20.0.0/16"
  }

  secondary_ip_range {
    range_name    = "gke-services-range"
    ip_cidr_range = "10.30.0.0/20"
  }
}

# Create a GKE Autopilot cluster
# Autopilot is recommended for simplified management and optimized costs for agent workloads.
resource "google_container_cluster" "primary" {
  project  = var.project_id
  name     = var.cluster_name
  location = var.region

  # Enable Autopilot mode
  enable_autopilot = true

  # Disable deletion protection for easier cleanup in dev/test environments.
  deletion_protection = false

  # Networking configuration
  network    = google_compute_network.vpc.id
  subnetwork = google_compute_subnetwork.subnet.id

  # IP allocation policy is automatically managed in Autopilot based on the subnet's secondary ranges.
  ip_allocation_policy {}

  # For agents that might need to call out to Google Cloud APIs (e.g., Vertex AI),
  # Workload Identity is the recommended secure way to grant access. It's enabled by default on Autopilot.
  workload_identity_config {
    workload_pool = "${var.project_id}.svc.id.goog"
  }

  # Ensure the GKE API is enabled before trying to create the cluster
  depends_on = [
    google_project_service.gke_api,
  ]
}

# ------------------------------------------------------------------------------
# Workload Identity & Permissions
# ------------------------------------------------------------------------------

# Create a Google Service Account (GSA) for the agent to use.
resource "google_service_account" "agent_gsa" {
  project      = var.project_id
  account_id   = var.gsa_name
  display_name = "Service Account for GKE Agent"
}

# Grant the GSA permission to use Vertex AI services.
resource "google_project_iam_member" "agent_gsa_aiplatform_user" {
  project = var.project_id
  # The "Vertex AI Service User" role is recommended for service accounts that need to
  # run jobs or make predictions, as it contains the necessary 'aiplatform.endpoints.predict' permission.
  role = "roles/aiplatform.user"
  member  = "serviceAccount:${google_service_account.agent_gsa.email}"
}

# Enable the Vertex AI API for the agent to use
resource "google_project_service" "vertex_ai" {
  project            = var.project_id
  service            = "aiplatform.googleapis.com"
  disable_on_destroy = false

  # Ensure the Service Usage API is enabled before trying to enable this one.
  depends_on = [
    google_project_service.service_usage
  ]
}

# Create the Kubernetes Service Account (KSA) and annotate it for Workload Identity.
# This annotation links the KSA to the GSA.
resource "kubernetes_service_account_v1" "agent_ksa" {
  metadata {
    name      = var.ksa_name
    namespace = "default" # Assuming default namespace
    annotations = {
      # The crucial annotation that links the KSA to the GSA
      "iam.gke.io/gcp-service-account" = google_service_account.agent_gsa.email
    }
  }
  # Ensure the GKE cluster is ready before trying to create Kubernetes resources in it.
  depends_on = [google_container_cluster.primary]
}

# Allow the Kubernetes Service Account (KSA) to impersonate the Google Service Account (GSA).
# This is the core binding for Workload Identity.
resource "google_service_account_iam_member" "agent_gsa_ksa_binding" {
  service_account_id = google_service_account.agent_gsa.name
  role               = "roles/iam.workloadIdentityUser"

  # The member format is: serviceAccount:PROJECT_ID.svc.id.goog[K8S_NAMESPACE/KSA_NAME]
  # We are using the "default" Kubernetes namespace here.
  member = "serviceAccount:${var.project_id}.svc.id.goog[default/${var.ksa_name}]"
}

# Enable the Artifact Registry API to store container images
resource "google_project_service" "artifact_registry" {
  project            = var.project_id
  service            = "artifactregistry.googleapis.com"
  disable_on_destroy = false
}

# Create an Artifact Registry repository to store the agent's container images.
resource "google_artifact_registry_repository" "agent_images_repo" {
  project       = var.project_id
  location      = var.region
  repository_id = var.ar_repo_name
  description   = "Docker repository for agent images"
  format        = "DOCKER"

  # Ensure the API is enabled before trying to create the repository.
  depends_on = [
    google_project_service.artifact_registry
  ]
}

# Grant the Cloud Build service account permissions to deploy to the GKE cluster.
# The "Kubernetes Engine Developer" role allows it to manage Kubernetes objects.
resource "google_project_iam_member" "cloudbuild_gke_developer" {
  project = var.project_id
  role    = "roles/container.developer"
  member  = "serviceAccount:${data.google_project.project.number}@cloudbuild.gserviceaccount.com"
}

# Grant the GKE nodes (which use the Compute Engine default service account by default)
# permission to pull images from Artifact Registry.
resource "google_project_iam_member" "gke_nodes_ar_reader" {
  project = var.project_id
  role    = "roles/artifactregistry.reader"
  member  = "serviceAccount:${data.google_project.project.number}-compute@developer.gserviceaccount.com"
}

# ------------------------------------------------------------------------------
# Data Sources
# ------------------------------------------------------------------------------

# Data source to get the configuration of the current Google Cloud client.
# This is used to configure the Kubernetes provider with the correct credentials.
data "google_client_config" "default" {}

# ------------------------------------------------------------------------------
# Provider Configurations
# ------------------------------------------------------------------------------
provider "kubernetes" {
  host                   = "https://${google_container_cluster.primary.endpoint}"
  token                  = data.google_client_config.default.access_token
  cluster_ca_certificate = base64decode(google_container_cluster.primary.master_auth[0].cluster_ca_certificate)
}

data "google_project" "project" {
  project_id = var.project_id
}

# ------------------------------------------------------------------------------
# Outputs
# ------------------------------------------------------------------------------

output "gke_cluster_name" {
  description = "The name of the GKE cluster."
  value       = google_container_cluster.primary.name
}

output "gke_cluster_endpoint" {
  description = "The endpoint of the GKE cluster."
  value       = google_container_cluster.primary.endpoint
  sensitive   = true
}

output "gke_cluster_location" {
  description = "The location (region) of the GKE cluster."
  value       = google_container_cluster.primary.location
}

output "agent_gsa_email" {
  description = "The email of the Google Service Account created for the agent."
  value       = google_service_account.agent_gsa.email
}