import os
from dotenv import load_dotenv

from google.adk import Agent

load_dotenv()

root_agent = Agent(
    name="transcript_summarizer",
    description="Summarizes chat transcripts.",
    # model=os.getenv("MODEL", "gemini-2.0-flash-exp"),
    model=os.getenv("MODEL", "gemini-2.5-pro"),
    instruction="Summarize the provided chat transcript.",
)
