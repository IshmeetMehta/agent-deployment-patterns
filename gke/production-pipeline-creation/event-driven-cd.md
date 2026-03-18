# Event-Driven Deployment with Eventarc

This document explains the **Asynchronous (Event-Driven)** deployment strategy, which decouples the build process from the deployment lifecycle using Google Cloud Eventarc and Cloud Audit Logs.

## Architecture Workflow

Rather than having the CI pipeline (Cloud Build) explicitly call Cloud Deploy, we monitor the **Artifact Registry** for new image uploads.

1.  **Image Push:** A new Docker image is pushed to Artifact Registry (either via a CI pipeline or manually).
2.  **Audit Log Entry:** Artifact Registry generates a Cloud Audit Log entry for the `google.devtools.artifactregistry.v1.ArtifactRegistry.ImportYumArtifacts` or `TagResource` / `PushImage` action.
3.  **Eventarc Trigger:** An Eventarc trigger is configured to listen for these specific Audit Log events.
4.  **Cloud Build Execution:** Eventarc triggers a specialized "CD-Trigger" Cloud Build job.
5.  **Repository Clone & Handoff:** This Cloud Build job clones the relevant service repository, hydrates the manifests with the new image tag, and executes:
    ```bash
    gcloud deploy releases create "release-${SHORT_SHA}" \
      --delivery-pipeline="${_APP_NAME}-pipeline" \
      --region="${_GCP_REGION}" \
      --images="my-agent-image=${_IMAGE_PATH}"
    ```
6.  **Cloud Deploy Rollout:** The delivery pipeline takes over the multi-cluster rollout.

## Why Cloud Audit Logs over GCS?

We prioritize **Cloud Audit Logs** for this trigger mechanism because:
*   **Scalability:** A single Eventarc trigger can be configured to monitor an entire Artifact Registry project or specific repositories, reducing the management toil of per-bucket triggers.
*   **Precision:** Audit logs provide rich metadata about the specific image tag and repository, allowing for more granular routing in the triggered Cloud Build job.
*   **Decoupling:** The CI process (building the image) remains completely unaware of the CD process (deploying the image), allowing teams to update their build logic without touching the deployment triggers.

## Implementation Guide

### 1. Enable Required Services
```bash
gcloud services enable eventarc.googleapis.com logging.googleapis.com
```

### 2. Configure IAM Permissions
The Eventarc Service Agent requires permission to trigger Cloud Build:
```bash
gcloud projects add-iam-policy-binding ${GCP_PROJECT_ID} \
    --member="serviceAccount:service-${PROJECT_NUMBER}@gcp-sa-eventarc.iam.gserviceaccount.com" \
    --role="roles/cloudbuild.builds.editor"
```

### 3. Create the Eventarc Trigger
Example command to trigger on a new container image being tagged in Artifact Registry:
```bash
gcloud eventarc triggers create image-deploy-trigger \
    --destination-cloud-build-config-file="cloudbuild-cd.yaml" \
    --event-filters="type=google.cloud.audit.log.v1.written" \
    --event-filters="serviceName=artifactregistry.googleapis.com" \
    --event-filters="methodName=google.devtools.artifactregistry.v1.ArtifactRegistry.TagResource" \
    --service-account="${PROJECT_NUMBER}-compute@developer.gserviceaccount.com"
```

## Cloud Build Configuration (CD-only)

In this event-driven model, the `cloudbuild.yaml` in your repository can be split. You can keep the **CI (Build/Push)** steps and the **CD (Deploy)** steps in the same file but use conditional steps or separate files (e.g., `cloudbuild-cd.yaml`) to avoid redundant builds.

*   **Option A:** Comment out the `Build` and `Push` steps if you only want the trigger to handle the deployment.
*   **Option B:** Use a single file and leverage Cloud Build's `allowFailure` or `substitutions` to skip build steps when triggered by Eventarc.

## References
*   [Eventarc Overview](https://cloud.google.com/eventarc/docs/overview)
*   [Create an Eventarc trigger for Cloud Audit Logs](https://cloud.google.com/eventarc/docs/run/create-trigger-auditlog-gcloud)
*   [Cloud Build - Creating Custom Triggers](https://cloud.google.com/build/docs/automate-builds-eventarc)
