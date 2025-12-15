#!/bin/bash

set -e

SERVICE_NAME=$1
IMAGE_REPO=$2
IMAGE_TAG=$3
ACR_LOGIN_SERVER=$4

git config --global user.email "azure-pipeline@devops.com"
git config --global user.name "Azure Pipeline"

REPO_URL="https://${AZURE_DEVOPS_EXT_PAT}@dev.azure.com/a-agboola/votingApp/_git/votingApp"

echo "Cloning repository..."
rm -rf /tmp/temp_repo
git clone "$REPO_URL" /tmp/temp_repo

cd /tmp/temp_repo

NEW_IMAGE_FULL="${ACR_LOGIN_SERVER}/${IMAGE_REPO}/vote:${IMAGE_TAG}"

echo "Updating deployment to use image: $NEW_IMAGE_FULL"

# Update K8s Manifest
if [ -f "k8s-specifications/${SERVICE_NAME}-deployment.yaml" ]; then
    sed -i "s|image:.*|image: ${NEW_IMAGE_FULL}|g" "k8s-specifications/${SERVICE_NAME}-deployment.yaml"
else
    echo "Error: Deployment file not found!"
    exit 1
fi

# Commit and Push
if [ -z "$(git status --porcelain)" ]; then
  echo "No changes to commit."
else
  git add .
  git commit -m "Update ${SERVICE_NAME} image to tag ${IMAGE_TAG}"
  git push
fi

cd ..
rm -rf /tmp/temp_repo