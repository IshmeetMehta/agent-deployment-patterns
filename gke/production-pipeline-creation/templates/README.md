# Agent Deployment Templates

This directory contains the base templates for deploying a GKE agent. These templates are designed to be hydrated into static Kubernetes manifest files using common variables.

## Deployment Strategy: Immutable Multi-Cluster

We use a **Senior Multi-Cluster Strategy** where the same manifests are promoted across isolated clusters (Dev, QA, Prod). This ensures environment parity and simplifies the deployment lifecycle.

### Key Principles:
1.  **Shared Namespace:** The Kubernetes Namespace is always `${APP_NAME}` in all clusters.
2.  **Shared Identity:** The Kubernetes Service Account is always `${APP_NAME}-sa`.
3.  **Cross-Cluster Promotion:** Google Cloud Deploy manages the rollout of the same container image and manifests across the 3 clusters.

## Template Files:

*   `01-namespace.yaml`: Defines the namespace for the agent.
*   `02-ksa.yaml`: Defines the Kubernetes Service Account with Workload Identity annotations.
*   `03-deployment.yaml`: Defines the core Deployment resource with best practices (probes, resources).
*   `04-service-lb.yaml`: Defines a LoadBalancer Service for external access.
*   `service-gateway.yaml`: An alternative template for using Gateway API instead of a LoadBalancer Service.
*   `cloudbuild.yaml`: The CI pipeline configuration for building and triggering deployments.
*   `clouddeploy.yaml`: The CD pipeline configuration defining environments and automation rules.
*   `skaffold.yaml`: The configuration for local development and post-deployment verification.

## Hydration Process:

These templates use placeholders like `${APP_NAME}`, `${GCP_PROJECT_ID}`, and `${GCP_REGION}`. During the generation phase, these must be replaced with actual values.

For detailed instructions on how to use these templates with AI automation or manual configuration, please refer to the root [README.md](../README.md), [instructions.md](../instructions.md), and [manual.md](../manual.md).
