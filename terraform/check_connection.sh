#!/bin/bash
# Usage: ./check_connection.sh [PROJECT_ID] [CONNECTION_NAME] [REGION]

PROJECT_ID=$1
NAME=$2
REGION=$3

echo "🔍 Checking status of Cloud Build connection: $NAME..."

while true; do
  # Fetch the installation state using gcloud
  STATE=$(gcloud alpha builds connections describe $NAME \
    --region=$REGION --project=$PROJECT_ID \
    --format="value(installationState.stage)")

  if [ "$STATE" == "COMPLETE" ]; then
    echo "✅ Connection is COMPLETE. Proceeding..."
    break
  elif [ "$STATE" == "PENDING_USER_ACTION" ] || [ "$STATE" == "PENDING_INSTALL_APP" ]; then
    echo "⚠️  Connection is $STATE."
    echo "👉 Please go to the GCP Console and 'Link' the repository or install the GitHub App."
    echo "🔗 https://console.cloud.google.com/cloud-build/repositories/2nd-gen/locations/$REGION?project=$PROJECT_ID"
    echo "⏳ Waiting 10 seconds before checking again..."
    sleep 10
  else
    echo "❓ Unknown state: $STATE. Waiting..."
    sleep 10
  fi
done
