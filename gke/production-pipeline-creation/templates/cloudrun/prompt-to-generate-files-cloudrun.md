This document outlines the variables and logic for generating a Cloud Run deployment pipeline for your agent.

## Core Variables:

*   **APP_NAME**: The name of your Cloud Run service.
*   **GCP_PROJECT_ID**: Your Google Cloud Project ID.
*   **GCP_REGION**: The region for Cloud Run deployment (e.g., `us-central1`).
*   **ARTIFACT_REGISTRY_LOCATION**: The region for your Docker repository.

## Cloud Run Strategy: Serverless Continuous Deployment

1.  **Skaffold Integration**: Use `skaffold.yaml` with the `cloudrun` deployer.
2.  **Cloud Deploy Targets**: Generate 3 Cloud Deploy targets (`-dev`, `-qa`, `-prod`) pointing to the Cloud Run service in the specified region.
3.  **Traffic Management**: Leverage Cloud Deploy's native support for Cloud Run to manage revisions and traffic splitting.

## Hydration Process:

*   Inject variables into `cloudbuild.yaml` to build and push the image.
*   Ensure `clouddeploy.yaml` uses the `run: service` target configuration instead of `gke`.
*   Maintain the same promotion and automation rules used in the GKE pipeline for consistency.
