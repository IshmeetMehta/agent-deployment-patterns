# agent-deployment-patterns

# Deploying an Agent to Vertex AI Agent Engine

This directory contains a sample project demonstrating how to deploy a conversational agent to **Vertex AI Agent Engine** using a CI/CD pipeline with Cloud Build.

The example showcases a "Transcript Summarizer" agent that can take a conversation transcript and produce a summary. The deployment is handled by a Python script using the Vertex AI SDK, and the entire process is automated with Cloud Build.

## Prerequisites

Before you begin, ensure you have the following:

1.  **A Google Cloud Project**: If you don't have one, create one in the [Google Cloud Console](https://console.cloud.google.com/).
2.  **gcloud CLI**: Make sure the [Google Cloud CLI](https://cloud.google.com/sdk/docs/install) is installed and authenticated.
3.  **Enabled APIs**: Enable the Vertex AI API for your project:
    ```sh
    gcloud services enable aiplatform.googleapis.com --project YOUR_PROJECT_ID
    ```
4.  **Permissions**:

    - The **Cloud Build service account** (`[PROJECT_NUMBER]@cloudbuild.gserviceaccount.com`) needs the following IAM roles to deploy and manage Vertex AI resources:
      - `Vertex AI User` (to deploy and test the agent)
      - `Storage Admin` (for the staging bucket)
      - `Service Account User` (to act as other service accounts)
    - The **agent's runtime service account** (by default, the Compute Engine default service account: `[PROJECT_NUMBER]-compute@developer.gserviceaccount.com`) needs the `Vertex AI User` role to be able to call the underlying LLM (e.g., Gemini).

    You can grant these permissions by running the provided Terraform configuration
    from this directory. You will be prompted for your project ID.

    ```sh
    terraform init && terraform apply
    ```

    Alternatively, you can provide the project ID directly on the command line:

    ```sh
    terraform apply -var="project_id=YOUR_PROJECT_ID"
    ```

## File Structure

- `agent.py`: Defines the core logic of the agent using the Agent Development Kit (ADK). This is where you define tools, instructions, and models.
- `deploy.py`: A Python script that uses the Vertex AI SDK (`vertexai.agent_engines.create`) to deploy the agent defined in `agent.py` to the Agent Engine.
- `cloudbuild.yaml`: The CI/CD pipeline definition for Cloud Build. It automates the deployment and testing process.
- `test_agent_engine.py`: A Python script to run integration tests against the _deployed_ agent on Vertex AI.
- `test_agent_app_locally.py`: A utility script to test the agent's logic on your local machine before deployment.
- `requirements.txt`: A list of Python dependencies required for the agent and deployment scripts.

## Local Development and Testing

It's good practice to test your agent's logic locally before deploying it.

1.  **Set up a virtual environment**:

    ```sh
    python3 -m venv venv
    source venv/bin/activate
    ```

2.  **Install dependencies**:

    ```sh
    pip install -r requirements.txt
    ```

3.  **Run the local test script**:
    This script initializes the agent and sends it a sample query, printing the response to the console.
    ```sh
    python test_agent_app_locally.py
    ```

## Deployment with Cloud Build

The `cloudbuild.yaml` file defines a two-step pipeline:

1.  **Deploy**: Runs the `deploy.py` script to deploy the agent to Vertex AI Agent Engine. It captures the resource name of the new agent for the next step.
2.  **Test**: Runs the `test_agent_engine.py` script, which uses the captured resource name to connect to the newly deployed agent and run an integration test.

To trigger the deployment, run the following command from this directory:

```sh
gcloud builds submit --config cloudbuild.yaml --substitutions=_LOCATION=us-central1 .
```

- `PROJECT_ID` is automatically substituted by Cloud Build.
- You can change `_LOCATION` to any supported Vertex AI region.

You can view the build logs in the Cloud Build section of the Google Cloud Console to monitor the deployment and test results.

## How It Works

### Deployment (`deploy.py`)

The `deploy.py` script is the core of the deployment logic.

- It initializes the Vertex AI SDK with your project, location, and the staging bucket.
- It calls `vertexai.agent_engines.create()`, passing in the `root_agent` imported from `agent.py`.
- The SDK handles packaging your code, its dependencies (`requirements.txt`), and uploading them to the staging bucket.
- It then provisions the necessary resources on Vertex AI Agent Engine and deploys your agent.
- Finally, the script prints the unique `resource_name` of the deployed agent, which looks like `projects/.../locations/.../agentEngines/...`.

### CI/CD Pipeline (`cloudbuild.yaml`)

The Cloud Build pipeline automates the process described above.

- **Step 1 (Deploy)**:

  - Sets up a Python environment and installs dependencies.
  - Runs `deploy.py`.
  - The output of `deploy.py` (containing the resource name) is saved to a file in the shared `/workspace`.

- **Step 2 (Test)**:
  - Sets up its own Python environment.
  - Reads the agent's `resource_name` from the file in `/workspace` and sets it as an environment variable (`AGENT_RESOURCE_NAME`).
  - Runs `test_agent_engine.py`, which reads this environment variable to connect to the correct agent and verify its functionality.

This two-step process ensures that you not only deploy your agent but also confirm that the deployment was successful and the agent is responsive.
