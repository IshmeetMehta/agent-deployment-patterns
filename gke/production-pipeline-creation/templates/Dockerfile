# Use an official Python runtime as a parent image
FROM python:3.9-slim-buster

# Set the working directory in the container
WORKDIR /app

# Copy the current directory contents into the container at /app
# This assumes your agent code is in the current directory
COPY . /app

# Install any needed packages specified in requirements.txt
# If you have a requirements.txt, uncomment the following lines:
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Make port 8080 available to the world outside this container
EXPOSE 8080

# Define environment variable
# ENV NAME World

# Run your agent application
# Replace 'your_agent_script.py' with the actual entry point of your agent
# For a different language, replace this with the appropriate command
CMD ["python", "your_agent_script.py"]
