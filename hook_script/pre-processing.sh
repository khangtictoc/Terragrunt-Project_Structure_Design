#! /bin/bash

function welcome-message() {
    echo "Post-Processing Script Initiated"
    echo "┌──────────────────────────────────────┐"
    echo "│                                      │"
    echo "│           PRE-PROCESSING             │"
    echo "│  - Clean up Terragrunt cache         │"
    echo "│  - Copy output to S3 bucket          │"
    echo "│                                      │"
    echo "└──────────────────────────────────────┘"
    echo
}

function kubeconfig-init(){
    echo "Initializing kubeconfig file..."
    KUBECONFIG_PATH="$HOME/.kube/config"
    mkdir -p "$HOME/.kube"
    echo ">>>>>>>>>>>> TEST >>>>>>>>>" > "$KUBECONFIG_PATH"
    echo "Kubeconfig file initialized at $KUBECONFIG_PATH"
}

function main() {
    source <(curl -sS https://raw.githubusercontent.com/khangtictoc/Productive-Workspace-Set-Up/refs/heads/main/linux/utility/library/bash/ansi_color.sh)
    init-ansicolor
    welcome-message
    kubeconfig-init

    echo "Pre-Processing Script Completed"
}

main "$@"