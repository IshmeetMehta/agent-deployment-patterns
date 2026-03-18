This document outlines the variables and logic for generating an Agent Engine deployment pipeline.

## Core Variables:

*   **AGENT_NAME**: The unique identifier for your agent.
*   **AGENT_LOCATION**: The Google Cloud location for Agent Engine (e.g., `us-central1`).
*   **GCP_PROJECT_ID**: Your Google Cloud Project ID.
*   **APP_VERSION**: The semantic version of your agent (e.g., `1.0.0`).

## Agent Engine Strategy: Custom Cloud Deploy Targets

1.  **Cloud Build Worker**: Since Agent Engine uses CLI/Python-based deployment (`uvx` or `python -m google.adk.cli`), we use a custom Cloud Build worker.
2.  **Custom Targets**: Configure Cloud Deploy with **Custom Targets** that trigger the Cloud Build worker during the `deploy` phase.
3.  **Lifecycle Management**: The Cloud Build worker handles the registration, versioning, and lifecycle management within Agent Engine.

## Hydration Process:

*   Generate a specialized `cloudbuild-deploy.yaml` that contains the Agent Engine CLI commands.
*   Hydrate `clouddeploy.yaml` to include the `customTarget` configuration pointing to the Cloud Build worker.
*   Ensure all environment-specific variables are passed to the custom target for correct routing.
