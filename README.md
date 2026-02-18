# Conversational Agent Deployment Patterns

This repository provides a collection of reference patterns for deploying conversational agents built with the Google Agent Development Kit (ADK) to various Google Cloud platforms. Each pattern includes the necessary infrastructure, deployment scripts, and CI/CD configurations to help you get started.

The primary goal is to demonstrate best practices for automating the deployment and testing of your agents in a scalable and maintainable way.

## Prerequisites

Before you begin, ensure you have the following tools and configurations set up:

1.  **A Google Cloud Project**: If you don't have one, create one in the [Google Cloud Console](https://console.cloud.google.com/).
2.  **gcloud CLI**: Make sure the [Google Cloud CLI](https://cloud.google.com/sdk/docs/install) is installed and authenticated with your Google Cloud account.
    ```sh
    gcloud auth login
    gcloud auth application-default login
    ```
3.  **Enabled APIs**: Ensure the following APIs are enabled for your project. You can enable them with:
    ```sh
    gcloud services enable aiplatform.googleapis.com container.googleapis.com run.googleapis.com artifactregistry.googleapis.com cloudbuild.googleapis.com --project YOUR_PROJECT_ID
    ```
4.  **Terraform**: If you plan to use Terraform to provision infrastructure, ensure it is installed (version >= 1.0).

## Deployment Patterns

This repository includes deployment patterns for the following Google Cloud platforms:

### 1. Vertex AI Agent Engine

This pattern demonstrates how to deploy an agent directly to the managed **Vertex AI Agent Engine**. This is the simplest and most direct way to get a conversational agent running on Google Cloud.

-   **Location**: `agent-patterns/agent-engine/`
-   **Method**: A Python script (`deploy.py`) uses the Vertex AI SDK to deploy the agent. This process is automated with a `cloudbuild.yaml` file for CI/CD.

#### Quickstart

1.  **Navigate to the directory**:
    ```sh
    cd agent-patterns/agent-engine
    ```
2.  **Set up permissions**:
    The Cloud Build service account requires permissions to manage Vertex AI and Cloud Storage. You can grant these by applying the provided Terraform configuration. You will be prompted for your project ID.
    ```sh
    terraform init && terraform apply
    ```
3.  **Submit the Cloud Build job**:
    This command triggers a pipeline that deploys your agent and then runs an integration test against the live deployment.
    ```sh
    gcloud builds submit --config cloudbuild.yaml --substitutions=_LOCATION=us-central1 .
    ```

For more details on local testing and the pipeline's inner workings, see the [Agent Engine README](./agent-patterns/agent-engine/README.md).

### 2. Google Kubernetes Engine (GKE)

This pattern shows how to containerize your agent and deploy it to a **GKE Autopilot cluster**. This approach is ideal when you need more control over the execution environment, networking, or wish to integrate the agent into an existing microservices architecture.

-   **Location**: `agent-patterns/gke/`
-   **Method**:
    1.  **Infrastructure**: Terraform is used to provision a GKE Autopilot cluster with Workload Identity enabled (`agent-patterns/gke/terraform/`).
    2.  **Deployment**: A `cloudbuild.yaml` pipeline builds a Docker container for the agent, pushes it to Artifact Registry, and applies a Kubernetes `deployment.yaml` to the GKE cluster.

#### Quickstart

1.  **Provision the GKE Cluster**:
    First, navigate to the Terraform directory and create the cluster.
    ```sh
    cd agent-patterns/gke/terraform
    ```
    Create a `terraform.tfvars` file with your project ID and desired region:
    ```hcl
    # terraform.tfvars
    project_id = "your-gcp-project-id"
    region     = "us-central1"
    ```
    Then, apply the configuration:
    ```sh
    terraform init && terraform apply
    ```
2.  **Connect to the cluster**:
    Configure `kubectl` to communicate with your new cluster.
    ```sh
    gcloud container clusters get-credentials $(terraform output -raw gke_cluster_name) --region $(terraform output -raw gke_cluster_location)
    ```
3.  **Deploy the Agent**:
    Navigate to the agent deployment directory and submit the Cloud Build job.
    ```sh
    cd ../agent-deployment
    gcloud builds submit --config cloudbuild.yaml --substitutions=_GKE_CLUSTER=$(terraform output -raw gke_cluster_name),_GKE_LOCATION=$(terraform output -raw gke_cluster_location) .
    ```
    The substitutions pass the cluster name and location from the Terraform output to the build pipeline.

For more details, see the [GKE Terraform README](./agent-patterns/gke/terraform/README.md).

### 3. Cloud Run

This pattern demonstrates how to deploy a containerized agent as a serverless application on **Cloud Run**. This is a highly scalable, cost-effective solution for agents that handle variable or intermittent traffic.

-   **Location**: `agent-patterns/cloudrun/`
-   **Method**: The `adk deploy cloud_run` command is used within a `cloudbuild.yaml` pipeline. This command handles building the container, pushing it to Artifact Registry, and deploying the service to Cloud Run automatically.

#### Quickstart

1.  **Navigate to the directory**:
    ```sh
    cd agent-patterns/cloudrun
    ```
2.  **Submit the Cloud Build job**:
    This command triggers a pipeline that uses the ADK to deploy the agent to Cloud Run and then runs a test to verify the deployment.
    ```sh
    gcloud builds submit --config cloudbuild.yaml --substitutions=_REGION=us-central1 .
    ```
    You can customize the service name, app name, and region by modifying the `substitutions` section in the `cloudbuild.yaml` file.

## Contributing

Contributions are welcome! If you have a new deployment pattern or an improvement to an existing one, please feel free to open a pull request.

When contributing, please ensure:
- Your code is well-documented.
- You include a `README.md` explaining the pattern and how to use it.
- You follow the existing structure and conventions of the repository.
