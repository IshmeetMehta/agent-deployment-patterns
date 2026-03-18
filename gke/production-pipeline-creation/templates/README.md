# GKE Agent Deployment Templates

This directory contains the base templates for deploying a GKE agent. These templates are designed to be hydrated by the Gemini CLI (this agent) into static Kubernetes manifest files for each environment (DEV, QA, PRD).

## Instructions for Usage:

### Generating Environment-Specific Files:
Please refer to the `prompt-to-generate-files.md` in the root directory for detailed instructions on how to generate the environment-specific static Kubernetes manifest files (e.g., `./env/dev/*.yaml`, `./env/qa/*.yaml`, `./env/prd/*.yaml`) using the Gemini CLI.

### Local Development (Skaffold):
To use Skaffold for local development or deploying a specific environment (after its static files have been generated into `./env/<env>/`), you would typically modify `skaffold.yaml` to point to the desired environment's manifests.

For example, to deploy the DEV environment's static manifests:
```yaml
# In skaffold.yaml
deploy:
  kubectl:
    manifests:
    - env/dev/*.yaml
```
Then run:
```bash
skaffold dev
# Or to build and deploy once:
skaffold run
```

### Cloud Build Execution:
The `cloudbuild.yaml` file defines the CI/CD pipeline. After you have generated the static Kubernetes manifest files for each environment (e.g., in `./env/dev/`), Cloud Build will use these pre-generated files.

To execute Cloud Build:
```bash
gcloud builds submit . --config=templates/cloudbuild.yaml \
  --substitutions=\
_APP_NAME="your-app-name",\
_GCP_PROJECT_ID="your-gcp-project-id",\
_GCP_REGION="your-gcp-region",\
_GKE_CLUSTER_NAME="your-gke-cluster-name",\
_ARTIFACT_REGISTRY_LOCATION="your-ar-location"
```
**Note**: The Cloud Build variables (starting with `_`) will be used for Docker image tagging and Cloud Deploy release creation. The Kubernetes manifest files themselves are expected to be pre-generated and static. You will need to ensure `skaffold.yaml` is correctly configured to point to the appropriate environment's manifests.

### Cloud Deploy:
The `clouddeploy.yaml` defines the delivery pipeline and targets for your application. After a successful Cloud Build, Cloud Deploy will manage the rollout to your DEV, QA, and PRD environments, using the static Kubernetes manifest files for each. Manual approvals are configured for QA and PRD environments.

**Important Note for Cloud Deploy Targets**: The Cloud Deploy targets (e.g., `${APP_NAME}-dev`, `${APP_NAME}-qa`, `${APP_NAME}-prd`) are configured to deploy into namespaces named `${APP_NAME}_dev`, `${APP_NAME}_qa`, and `${APP_NAME}_prd` respectively. These namespaces **must be pre-created** in your GKE cluster before initiating a Cloud Deploy release.