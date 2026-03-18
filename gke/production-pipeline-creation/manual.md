# Manual Pipeline Setup Guide

Follow these steps to manually configure and deploy your agent pipeline using the templates provided in this repository.

## 1. Variable Substitution
Before applying any manifests, you must replace the placeholders in the `templates/` folder. Use the following mapping:

| Placeholder | Description | Example |
| :--- | :--- | :--- |
| `${APP_NAME}` | Your agent's unique name | `travel-agent` |
| `${GCP_PROJECT_ID}` | Your Google Cloud Project ID | `my-project-123` |
| `${GCP_REGION}` | The region for GKE and Artifact Registry | `us-central1` |
| `${CLUSTER_NAME}` | The prefix for your 3 clusters | `agent-cluster` |
| `${_VERSION}` | The version tag for your image | `v1.0.0` |

### Files to Update:
*   `cloudbuild.yaml`: Update image paths and substitution defaults.
*   `clouddeploy.yaml`: Update target cluster resource paths and service account emails.
*   `skaffold.yaml`: Update the image name and the verification `wget` URLs.
*   `k8s-manifests/*.yaml`: Update names, namespaces, and Workload Identity annotations.

## 2. Infrastructure Provisioning
If your clusters do not exist, execute the following (or use your Terraform equivalent):

1.  **Enable APIs:**
    ```bash
    gcloud services enable \
      cloudbuild.googleapis.com \
      clouddeploy.googleapis.com \
      container.googleapis.com \
      artifactregistry.googleapis.com \
      aiplatform.googleapis.com
    ```
2.  **Create Clusters:**
    Create 3 GKE Autopilot clusters named `${CLUSTER_NAME}-dev`, `${CLUSTER_NAME}-qa`, and `${CLUSTER_NAME}-prod`.
3.  **Setup Artifact Registry:**
    ```bash
    gcloud artifacts repositories create ${APP_NAME}-repo \
      --repository-format=docker \
      --location=${GCP_REGION}
    ```

## 3. Establish the Pipeline
1.  **Apply Cloud Deploy Configuration:**
    ```bash
    gcloud deploy apply --file=clouddeploy.yaml --region=${GCP_REGION} --project=${GCP_PROJECT_ID}
    ```
2.  **Create Cloud Build Trigger:**
    Connect your repository to Cloud Build and create a trigger pointing to `cloudbuild.yaml`. Ensure you pass the `_VERSION` substitution variable if your trigger is not based on git tags.

## 4. Verification Tests
The `skaffold.yaml` includes placeholder tests using Alpine Linux. To customize these:
*   Open `skaffold.yaml`.
*   The tests use `wget` to ping the internal service DNS: `${APP_NAME}.${APP_NAME}.svc.cluster.local`.
*   Replace the `args` in the `verify` section with your actual integration test scripts or endpoint health checks.
*   Remember that these tests run **inside** the cluster using the `executionMode: kubernetesCluster` setting.
