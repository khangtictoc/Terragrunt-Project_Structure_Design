#!/bin/bash

# Variables
BUCKET_NAME="terragrunt-state-backend"
DYNAMODB_TABLE_NAME="terragrunt-state-lock"
REGION="us-east-1"

# Create S3 bucket if it does not exist
if ! aws s3api head-bucket --bucket "$BUCKET_NAME" 2>/dev/null; then
  aws s3api create-bucket --bucket "$BUCKET_NAME" --region "$REGION"
  echo "S3 bucket $BUCKET_NAME created."
else
  echo "S3 bucket $BUCKET_NAME already exists."
fi

# Create DynamoDB table if it does not exist
if ! aws dynamodb describe-table --table-name "$DYNAMODB_TABLE_NAME" 2>/dev/null; then
  aws dynamodb create-table \
    --table-name "$DYNAMODB_TABLE_NAME" \
    --attribute-definitions AttributeName=LockID,AttributeType=S \
    --key-schema AttributeName=LockID,KeyType=HASH \
    --provisioned-throughput ReadCapacityUnits=5,WriteCapacityUnits=5 \
    --region "$REGION"
  echo "DynamoDB table $DYNAMODB_TABLE_NAME created."
else
  echo "DynamoDB table $DYNAMODB_TABLE_NAME already exists."
fi