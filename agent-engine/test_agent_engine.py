import os
import sys
import vertexai
from vertexai import agent_engines
from google.api_core import exceptions

# --- Configuration ---
# This assumes you are running this in an environment like Cloud Build
# where these environment variables are populated.
PROJECT_ID = os.environ.get("GOOGLE_CLOUD_PROJECT")
LOCATION = os.environ.get("GOOGLE_CLOUD_LOCATION")

# The full resource name for your deployed agent.
# Format: projects/PROJECT_ID/locations/LOCATION/agentEngines/AGENT_ENGINE_ID
AGENT_RESOURCE_NAME = os.environ.get("AGENT_RESOURCE_NAME")

def test_summarization_agent():
    """Initializes the SDK, queries the remote agent, and prints its response."""

    print("--- Client Configuration ---")
    print(f"Project ID: {PROJECT_ID}")
    print(f"Location: {LOCATION}")
    print(f"Agent Resource Name: {AGENT_RESOURCE_NAME}")
    print("-" * 28)

    # Ensure all required environment variables are set
    if not all([PROJECT_ID, LOCATION, AGENT_RESOURCE_NAME]):
        print("\nError: GOOGLE_CLOUD_PROJECT, GOOGLE_CLOUD_LOCATION, and AGENT_RESOURCE_NAME environment variables must be set.", file=sys.stderr)
        sys.exit(1)

    try:
        # Initialize the Vertex AI SDK
        vertexai.init(project=PROJECT_ID, location=LOCATION)

        print(f"\n--- Getting remote agent: {AGENT_RESOURCE_NAME} ---")
        # Get a client for the deployed agent engine
        remote_agent = agent_engines.get(AGENT_RESOURCE_NAME)

        # --- Session-based Interaction ---
        user_id = "user_ci_cd_test"  # A unique identifier for the end-user
        print(f"\n--- Creating session for user: {user_id} ---")
        # Create a new session for a stateful conversation
        session = remote_agent.create_session(user_id=user_id)
        print(f"Session created: {session['id']}")

        chat_transcript = """
        User: Hi, I need to check the status of my order, number 12345.
        Agent: I can help with that. One moment.
        Agent: I see that order 12345 has been shipped and is scheduled for delivery tomorrow.
        User: Excellent, thank you!
        """

        print("\n--- Sending transcript to the agent for summarization... ---")
        # Stream the query and handle the response
        print("\nSending transcript to the agent for summarization...")
        for event in remote_agent.stream_query(
            user_id=user_id,
            session_id=session['id'],
            message=chat_transcript,        
        ):
        # print(event)
            print("Complete event :", event)
            print("[remote test]" + event["content"]["parts"][0]["text"])
    
        print() # Add a final newline for clean formatting

        
        print("\n" + "-" * 50)
        print("--- Test Succeeded ---")
        print("-" * 50)

    # Add specific error handling for common issues
    except exceptions.PermissionDenied as e:
        print(f"\n[ERROR] Permission Denied: The service account does not have the required 'aiplatform.endpoints.predict' permission.", file=sys.stderr)
        print("Please grant the 'Vertex AI User' role (roles/aiplatform.user) to the principal running this script.", file=sys.stderr)
        sys.exit(1)
    except exceptions.NotFound as e:
        print(f"\n[ERROR] Not Found: The agent resource '{AGENT_RESOURCE_NAME}' could not be found.", file=sys.stderr)
        print("Please verify that the AGENT_RESOURCE_NAME is correct and the agent is deployed.", file=sys.stderr)
        sys.exit(1)
    except Exception as e:
        print(f"\n[ERROR] An unexpected error occurred: {e}", file=sys.stderr)
        sys.exit(1)

    # Deleting user session after use
    print(f"\n--- Deleting session for user: {user_id} ---")
    remote_agent.delete_session(user_id=user_id, session_id=session["id"])
    print(f"Deleted session for user ID: {user_id}")

if __name__ == "__main__":
    test_summarization_agent()