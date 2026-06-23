#!/usr/bin/env bash
set -euo pipefail

# Usage: ./push-to-ecr.sh <image-tag>
TAG=${1:-latest}
PROJECT="patient-service"

ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
REGION=$(aws configure get region || echo us-east-1)
REPO="${ACCOUNT_ID}.dkr.ecr.${REGION}.amazonaws.com/${PROJECT}"

# Build
docker build -t ${PROJECT}:${TAG} .

# Create ECR repo if not exists
aws ecr describe-repositories --repository-names "${PROJECT}" >/dev/null 2>&1 || \
  aws ecr create-repository --repository-name "${PROJECT}"

# Login and push
aws ecr get-login-password --region ${REGION} | docker login --username AWS --password-stdin ${ACCOUNT_ID}.dkr.ecr.${REGION}.amazonaws.com

docker tag ${PROJECT}:${TAG} ${REPO}:${TAG}
docker push ${REPO}:${TAG}

echo "Pushed ${REPO}:${TAG}"

echo "If you used Terraform in deployment/terraform, run: terraform output -raw ecr_repository_url to get repo URL."
