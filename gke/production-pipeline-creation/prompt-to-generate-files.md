This document outlines the variables used in the generated GKE deployment templates. These variables must be replaced with actual values during the manifest hydration process.

## Core Variables:

*   **APP_NAME**: A unique name for your application. This name is the foundational identifier for all resources (Namespace, Service, Deployment, Service Account).
    *   *Example*: `my-cool-agent`

*   **GCP_PROJECT_ID**: Your Google Cloud Project ID.
    *   *Current Placeholder Value*: `my-project-123`

*   **GCP_REGION**: The Google Cloud region where your resources will be deployed (e.g., `us-central1`).
    *   *Current Placeholder Value*: `us-central1`

*   **CLUSTER_NAME**: The prefix for your 3 GKE clusters (`-dev`, `-qa`, `-prod`).

*   **ARTIFACT_REGISTRY_LOCATION**: The Google Cloud region for your Artifact Registry (e.g., `us-central1`).

*   **APP_PORT**: The port on which your agent application listens (Default: `8080`).

## Environment Strategy: Immutable Multi-Cluster

We use a **Multi-Cluster** strategy with **Immutable Manifests**. This means the same files in `/k8s-manifests` are used across all clusters.

1.  **Shared Namespace:** The Kubernetes Namespace name is simply `${APP_NAME}` in all clusters (Dev, QA, Prod).
2.  **Shared Identity:** The Kubernetes Service Account name is `${APP_NAME}-sa` in all clusters.
3.  **Cross-Cluster Promotion:** Google Cloud Deploy promotes the same container image and manifests across the 3 clusters, ensuring environment parity.

## Instructions for Manifest Generation:

In this project, templates are hydrated by Gemini CLI (this agent) to produce static Kubernetes manifest files.

**Workflow:**

1.  **Hydrate Manifests:**
    *   Inject the `APP_NAME`, `GCP_PROJECT_ID`, and `GCP_REGION` into the templates.
    *   Ensure the Alpine test `wget` command in `skaffold.yaml` is correctly pointed to: `${APP_NAME}.${APP_NAME}.svc.cluster.local`.
2.  **Save to Root Manifest Folder:**
    *   Save all hydrated `.yaml` files (Namespace, KSA, Deployment, Service) into the `/k8s-manifests/` directory in the project root.
3.  **Pipeline Generation:**
    *   Inject variables into `cloudbuild.yaml`, `clouddeploy.yaml`, and `skaffold.yaml`.
    *   Ensure `clouddeploy.yaml` points to the 3 target clusters: `${CLUSTER_NAME}-dev`, `${CLUSTER_NAME}-qa`, and `${CLUSTER_NAME}-prod`.

**Important Considerations:**

*   **Workload Identity:** The `02-ksa.yaml` template includes the necessary annotation for Workload Identity. Ensure the Project ID is correctly injected into the GCP Service Account email placeholder.
*   **Alpine Test Placeholders:** The Alpine containers in `skaffold.yaml` are placeholders. Developers should replace the `wget` commands with their specific endpoint or integration tests as the project matures.
*   **Gateway API vs. LoadBalancer:** If the user chose Gateway API, ensure `04-service.yaml` is generated as `type: ClusterIP` and the appropriate `Gateway` and `HTTPRoute` resources are created in its place.
