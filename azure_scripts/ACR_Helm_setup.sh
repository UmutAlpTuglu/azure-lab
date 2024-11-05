#!/bin/bash
set -e

ACR_NAME="dummy"
RESOURCE_GROUP="dummy"    
SUBSCRIPTION_ID="dummy"

# Service Principal Names - you can customize these
SP_NAME_PUSH="helm-chart-push"

# Create Service Principal for Push access
echo "Creating Service Principal for PUSH access..."
SP_PUSH_PASSWORD=$(az ad sp create-for-rbac \
    --name "${SP_NAME_PUSH}" \
    --scopes "/subscriptions/${SUBSCRIPTION_ID}/resourceGroups/${RESOURCE_GROUP}/providers/Microsoft.ContainerRegistry/registries/${ACR_NAME}" \
    --role acrpush \
    --query "password" \
    --output tsv)

SP_PUSH_ID=$(az ad sp list \
    --display-name "${SP_NAME_PUSH}" \
    --query "[].appId" \
    --output tsv)

echo "Push Service Principal created:"
echo "ID: $SP_PUSH_ID"
echo "Password: $SP_PUSH_PASSWORD"