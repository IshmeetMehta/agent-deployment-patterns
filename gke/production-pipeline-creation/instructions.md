# Instructions

## Goal

The intent of this file is to provide context for promoting an agent to production on GKE, following Google's best practices.
You will generate the manifests and infrastructure scripts (or Terraform) required for a production-grade CI/CD pipeline.

## Required Information from the User

ALWAYS request all information below to ensure we deploy to the correct location. Request the info one by one in a nice colored user prompt.

**User Input Questions:**
1.  **Application Name:** (e.g., `my-agent`)
2.  **Project ID:** (e.g., `my-project-123`)
3.  **Region:** (e.g., `us-central1`)
4.  **Cluster Prefix:** (The prefix for the 3 clusters: `-dev`, `-qa`, `-prod`)
5.  **Infrastructure Tool:** (Do you want to use `gcloud` scripts or `Terraform`?)
6.  **Provisioning:** (Do you want to create the 3 GKE Autopilot clusters now or do they already exist?)
7.  **Ingress Type:** (Standard `LoadBalancer` or `Gateway API`?)

**RULE:** If the user does not confirm all inputs, ask again.

## Deployment Strategy: Multi-Cluster (Standard)

We follow a **Production-Grade Multi-Cluster Strategy**. This ensures your deployment manifests are **immutable** and isolated.
-   **Environment Isolation:** 3 separate GKE Autopilot clusters (`${CLUSTER_NAME}-dev`, `${CLUSTER_NAME}-qa`, `${CLUSTER_NAME}-prod`).
-   **Single Namespace:** The agent is deployed into a namespace named `${APP_NAME}` in all three clusters.
-   **Manifest Immutability:** The same manifests in `/k8s-manifests` are promoted across environments by Google Cloud Deploy.

## Infrastructure Setup

Depending on the user's choice (gcloud/Terraform), generate the corresponding files to:
1.  **Enable APIs:** Cloud Build, Cloud Deploy, GKE, AR, GCS, Vertex AI, Eventarc.
2.  **Artifact Registry:** Create a Docker repository named `${APP_NAME}-repo`.
3.  **GKE Clusters:** (If provisioning is requested) Create 3 GKE Autopilot clusters using the specified region and names.
4.  **IAM & Security:** 
    *   Configure Cloud Build SA with `roles/artifactregistry.writer`, `roles/container.developer`, and `roles/clouddeploy.releaser`.
    *   Create a **Google Service Account (GSA)** named `${APP_NAME}-sa`.
    *   Grant the GSA `roles/aiplatform.user`.
    *   **Workload Identity:** Bind the GSA to the Kubernetes Service Account (KSA) `${APP_NAME}-sa` in the namespace `${APP_NAME}`.

## Pipeline Components

1.  **CI (Cloud Build):** Triggered by Git events. Builds the Docker image, tags it with `${_VERSION}`, pushes to Artifact Registry, and triggers Cloud Deploy.
2.  **CD (Cloud Deploy):** Manages the rollout across Dev, QA, and Prod clusters.
3.  **Automated Verification (Skaffold):** 
    *   Uses **Alpine Linux** containers to run smoke tests after each deployment.
    *   **Note:** These Alpine steps are **placeholders** for your specific integration and endpoint tests.
    *   Tests run inside the cluster to validate internal service DNS: `${APP_NAME}.${APP_NAME}.svc.cluster.local`.
4.  **Automation:** Successful Dev deployments are automatically promoted to QA. Production requires manual approval.

## Implementation Steps

1.  **Root Folder:** Create a root folder for the project.
2.  **Agent Logic:** Add the agent folder and files (`main.py`, `requirements.txt`, `Dockerfile`).
3.  **Manifest Generation:** Generate the K8s manifests in `/k8s-manifests` using the provided [templates/](./templates/).
4.  **Pipeline Generation:** Generate `cloudbuild.yaml`, `clouddeploy.yaml`, and `skaffold.yaml` in the root using our [templates/](./templates/).
5.  **Infrastructure Generation:** Generate `deploy.sh` (or Terraform files) in the root.
6.  **Final Summary:** Provide the user with a summary of the generated files and the commands to start the deployment.
