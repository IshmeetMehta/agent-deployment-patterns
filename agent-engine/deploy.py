import os
import sys
import vertexai
from vertexai import agent_engines
from vertexai.preview import reasoning_engines
from google.api_core import exceptions
from dotenv import load_dotenv
from vertexai.preview.reasoning_engines import AdkApp


# Import your agent's root object to be packaged
from agent import root_agent

# Load environment variables from a .env file for local execution
load_dotenv()

# --- Configuration ---
PROJECT_ID = os.getenv("GOOGLE_CLOUD_PROJECT")
LOCATION = os.getenv("GOOGLE_CLOUD_LOCATION")
# It's good practice to make the bucket name unique and explicit
STAGING_BUCKET_NAME = f"gs://{PROJECT_ID}-adk-staging-bucket"
APP_NAME = os.getenv("APP_NAME", "My Deployed Agent")

# --- CRITICAL: Agent Dependencies ---
# You MUST list all Python libraries that your agent code (`agent.py` and its
# tools) depends on. If a dependency is missing here, the deployment will
# succeed, but the agent will crash at runtime when it tries to use it.
AGENT_REQUIREMENTS = [
    "google-cloud-aiplatform[adk,agent_engines]"
]

def deploy_agent():
    """
    Initializes Vertex AI, creates an AdkApp, deploys it to Agent Engine,
    and handles common errors.
    """
    print("--- Starting Agent Deployment ---")
    print(f"Project: {PROJECT_ID}, Location: {LOCATION}")
    print(f"Staging Bucket: {STAGING_BUCKET_NAME}")
    print(f"App Name: {APP_NAME}")
    
    # Validate environment configuration
    if not all([PROJECT_ID, LOCATION]):
        print("\n[ERROR] GOOGLE_CLOUD_PROJECT and GOOGLE_CLOUD_LOCATION environment variables must be set.", file=sys.stderr)
        sys.exit(1)

    try:
        # Initialize Vertex AI SDK with the required staging bucket
        print("\n[TRACE] Initializing Vertex AI SDK...")
        vertexai.init(
            project=PROJECT_ID,
            location=LOCATION,
            staging_bucket=STAGING_BUCKET_NAME,
        )
        print("[TRACE] SDK Initialized.")

        # Create the AdkApp object
        # This is the modern way to package your agent for both local testing and deployment.
        print("[TRACE] Creating AdkApp object...")
        adk_app = reasoning_engines.AdkApp(
            agent=root_agent,
            enable_tracing=True, # Recommended for debugging
        )
        print("[TRACE] AdkApp object created.")

        # Deploy the AdkApp to Agent Engine
        print(f"\n[TRACE] Deploying agent '{APP_NAME}'...")
        remote_app = agent_engines.create(
            adk_app,
            display_name=APP_NAME,
            requirements=AGENT_REQUIREMENTS,
        )

        # Print the resource name for use in CI/CD pipelines
        resource_name = remote_app.resource_name
        print("\n" + "="*50)
        print("--- ✅ Deployment Succeeded! ---")
        print(f"Deployed Agent Resource Name: {resource_name}")
        print("="*50)
        
        # Save the resource name to a file for the next step in your pipeline
        with open("agent_resource_name.txt", "w") as f:
            f.write(resource_name)
        print("Resource name also saved to agent_resource_name.txt")

    # Handle common deployment errors
    except exceptions.PermissionDenied as e:
        print("\n[ERROR] Permission Denied. The principal running this script is missing required IAM roles.", file=sys.stderr)
        print("Ensure it has 'Vertex AI User', 'Service Account User', and 'Storage Object Admin'.", file=sys.stderr)
        sys.exit(1)
        
    except exceptions.NotFound as e:
        print(f"\n[ERROR] A resource was not found. This is likely the staging bucket: '{STAGING_BUCKET_NAME}'.", file=sys.stderr)
        print("Please ensure the GCS bucket exists before running this script. You can create it with 'gcloud storage buckets create ...'", file=sys.stderr)
        sys.exit(1)

    except Exception as e:
        print(f"\n[ERROR] An unexpected error occurred during deployment: {e}", file=sys.stderr)
        sys.exit(1)


if __name__ == "__main__":
    deploy_agent()