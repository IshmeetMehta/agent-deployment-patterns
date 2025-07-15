# Use an official lightweight Python image.
# https://hub.docker.com/_/python
FROM python:3.13-slim

# Set the working directory in the container.
WORKDIR /app

# Copy the requirements file into the container.
COPY requirements.txt .
# Install the dependencies.
RUN pip install --no-cache-dir -r requirements.txt

# Create a non-root user and grant ownership of the app directory for security.
RUN adduser --disabled-password --gecos "" myuser && \
    chown -R myuser:myuser /app

# Copy the rest of the application code (e.g., agent.py) into the container.
COPY . .

# Switch to the non-root user.
USER myuser

ENV PATH="/home/myuser/.local/bin:$PATH"

# Set the command to run the FastAPI application using uvicorn.
# The shell form is used to allow environment variable substitution for $PORT.
CMD ["sh", "-c", "uvicorn main:app --host 0.0.0.0 --port $PORT"]