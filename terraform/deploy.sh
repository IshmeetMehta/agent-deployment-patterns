#!/bin/bash
set -e

# Usage: ./deploy.sh [PROJECT_ID] [GITHUB_PAT] [REPO_OWNER] [REPO_NAME]

if [ -z "$REPO_NAME" ]; then
    echo "Usage: ./deploy.sh [PROJECT_ID] [GITHUB_PAT] [REPO_OWNER] [REPO_NAME]"
    exit 1
fi

echo "🎯 Setting project to $PROJECT_ID..."
gcloud config set project "$PROJECT_ID"

echo "🔌 Enabling APIs (this can take a minute)..."
gcloud services enable \
    cloudbuild.googleapis.com \
    secretmanager.googleapis.com \
    compute.googleapis.com \
    logging.googleapis.com

echo "⏳ Waiting for Service Agents to propagate..."
sleep 15 

# Force trigger the creation of the Cloud Build Service Agent if it doesn't exist
# We do this by simply calling the API's 'get' method
gcloud beta services identity create --service=cloudbuild.googleapis.com --project="$PROJECT_ID" || true

echo "🚀 Initializing Terraform..."
terraform init

echo "🛠 Deploying CI/CD Pipeline..."
terraform apply -auto-approve \
  -var="project_id=$PROJECT_ID" \
  -var="github_pat=$GITHUB_PAT" \
  -var="github_owner=$REPO_OWNER" \
  -var="repo_name=$REPO_NAME"

echo "✅ Deployment Complete! Your folders are now tracked by Cloud Build."
