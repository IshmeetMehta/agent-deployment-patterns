import os
import vertexai
from vertexai import agent_engines
import json

# --- Configuration ---
# This assumes you are running this in a CI/CD environment like Cloud Build
# where these environment variables are pre-populated.
PROJECT_ID = os.environ.get("GOOGLE_CLOUD_PROJECT")
LOCATION = os.environ.get("GOOGLE_CLOUD_LOCATION")
AGENT_RESOURCE_NAME = os.environ.get("AGENT_RESOURCE_NAME")

def test_summarization_agent():
    """Initializes the SDK, queries the remote agent, and prints its response."""

    # Ensure all required environment variables are set
    if not all([PROJECT_ID, LOCATION, AGENT_RESOURCE_NAME]):
        print("Error: GOOGLE_CLOUD_PROJECT, GOOGLE_CLOUD_LOCATION, and AGENT_RESOURCE_NAME environment variables must be set.")
        return

    vertexai.init(project=PROJECT_ID, location=LOCATION)

    print(f"--- Getting remote agent: {AGENT_RESOURCE_NAME} ---")
    # Get a client for the deployed agent engine
    remote_agent = agent_engines.get(AGENT_RESOURCE_NAME)
    

    # Print the available operations and their schemas for the agent
    # print("\n--- Supported Agent Schemas ---")
    # Use json.dumps for better formatting of the schemas
    # print(json.dumps(remote_agent.operation_schemas(), indent=2))
    
    # --- Session-based Interaction ---
    user_id = "user_12345" # A unique identifier for the end-user
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

    print("\nSending transcript to the agent for summarization...")
    for event in remote_agent.stream_query(
        user_id=user_id,
        session_id=session['id'],
        message=chat_transcript,        
        ):
        # print(event)
        print("[remote test]" + event["content"]["parts"][0]["text"])
    
    print() # Add a final newline for clean formatting


if __name__ == "__main__":
    # Call the function directly without asyncio
    test_summarization_agent()