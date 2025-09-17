#! /bin/bash

function welcome-message() {
    echo "Post-Processing Script Initiated"
    echo "┌──────────────────────────────────────┐"
    echo "│                                      │"
    echo "│           POST-PROCESSING            │"
    echo "│  - Clean up Terragrunt cache         │"
    echo "│  - Copy output to S3 bucket          │"
    echo "│                                      │"
    echo "└──────────────────────────────────────┘"
    echo
}

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

    FOLDER_PATH="$1"
    BUCKET_NAME="$2"

    # Check if AWS CLI is installed
    if ! command -v aws &> /dev/null; then
        echo "Error: AWS CLI is not installed"
        exit 1
    fi

    # Check if folder exists
    if [ ! -d "$FOLDER_PATH" ]; then
        echo -e "${YELLOW}[WARNING]${NC} Folder '$FOLDER_PATH' does not exist. Skipping S3 sync."
    else
        echo "Starting sync from '$FOLDER_PATH' to s3://$BUCKET_NAME/"
        aws s3 sync "$FOLDER_PATH" "s3://$BUCKET_NAME/" --delete
        # Check if sync was successful
        if [ $? -eq 0 ]; then
            echo "Successfully synced contents to S3 bucket"
        else
            echo "Error: Failed to sync contents to S3 bucket"
            exit 1
        fi
    fi
}

function main() {
    source <(curl -sS https://raw.githubusercontent.com/khangtictoc/Productive-Workspace-Set-Up/refs/heads/main/linux/utility/library/bash/ansi_color.sh)
    init-ansicolor
    welcome-message
    #clean-cache
    copy-output-to-s3 "$1" "$2"
    echo "Post-Processing Script Completed"
}

main "$@"