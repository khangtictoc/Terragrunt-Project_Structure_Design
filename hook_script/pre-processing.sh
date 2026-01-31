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
    cat <<-EOF > "$KUBECONFIG_PATH"
apiVersion: v1
kind: Config
preferences: {}

clusters:
- name: my-cluster
  cluster:
    server: https://127.0.0.1:6443
    certificate-authority: /home/user/.kube/ca.crt

users:
- name: my-user
  user:
    client-certificate: /home/user/.kube/client.crt
    client-key: /home/user/.kube/client.key

contexts:
- name: my-context
  context:
    cluster: my-cluster
    user: my-user
    namespace: default

current-context: my-context
EOF

    echo "Kubeconfig file initialized at $KUBECONFIG_PATH"
    cat "$KUBECONFIG_PATH"
}

function main() {
    source <(curl -sS https://raw.githubusercontent.com/khangtictoc/Productive-Workspace-Set-Up/refs/heads/main/linux/utility/library/bash/ansi_color.sh)
    init-ansicolor
    welcome-message
    kubeconfig-init

    echo "Pre-Processing Script Completed"
}

main "$@"