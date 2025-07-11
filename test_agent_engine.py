import os
import vertexai
from vertexai.preview import reasoning_engines

from agent import root_agent

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

    agent_app = reasoning_engines.AdkApp(
        agent=root_agent,
        enable_tracing=True,
    )

    chat_transcript = """
    User: Hi, I need to check the status of my order, number 12345.
    Agent: I can help with that. One moment.
    Agent: I see that order 12345 has been shipped and is scheduled for delivery tomorrow.
    User: Excellent, thank you!
    """
    session = agent_app.create_session(user_id="u_123")

    for event in agent_app.stream_query(
        user_id="u_123",
        session_id=session.id,
        message=chat_transcript,
    ):
        print("[local test] " + event["content"]["parts"][0]["text"])


if __name__ == "__main__":
    # Call the function directly without asyncio
    test_summarization_agent()