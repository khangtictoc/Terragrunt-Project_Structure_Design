#! /bin/bash

function clean-cache() {
    echo "Cleaning up .terragrunt-cache directories..."
    find . -type d -name ".terragrunt-cache" -prune -exec rm -rf {} \;
    echo "Clean-up complete!"
}

function copy-output-to-s3() {
    if [ "$#" -ne 2 ]; then
        echo "Error: Required arguments missing"
        echo "Usage: $0 <folder_path> <bucket_name>"
        exit 1
    fi

    # Assign arguments to variables
    FOLDER_PATH="$1"
    BUCKET_NAME="$2"
    echo $FOLDER_PATH
    echo $BUCKET_NAME

    # Check if folder exists
    if [ ! -d "$FOLDER_PATH" ]; then
        echo "Error: Folder '$FOLDER_PATH' does not exist"
        exit 1
    fi

    # Check if AWS CLI is installed
    if ! command -v aws &> /dev/null; then
        echo "Error: AWS CLI is not installed"
        exit 1
    fi

    echo "Starting sync from '$FOLDER_PATH' to s3://$BUCKET_NAME/"

    # Sync folder to S3 bucket
    aws s3 sync "$FOLDER_PATH" "s3://$BUCKET_NAME/" --delete

    # Check if sync was successful
    if [ $? -eq 0 ]; then
        echo "Successfully synced contents to S3 bucket"
    else
        echo "Error: Failed to sync contents to S3 bucket"
        exit 1
    fi
}

copy-output-to-s3 "$@"
# clean-cache