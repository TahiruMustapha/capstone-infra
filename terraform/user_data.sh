#!/bin/bash
# Deployment ID: ${deployment_id}

# --- Robust Logging Setup ---
LOG_FILE="/var/log/user_data.log"
exec > >(tee -a $LOG_FILE /var/log/cloud-init-output.log) 2>&1

echo "--- User Data Script Started: $(date) ---"

# Exit on error, undefined variables, or pipe failures
set -euo pipefail

# Update and Install Docker
sudo apt-get update -y
sudo apt-get install -y ca-certificates curl gnupg lsb-release

sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt-get update -y
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin

# Setup App Directory
echo "Setting up application directory..."
mkdir -p /home/ubuntu/app
sudo chown -R ubuntu:ubuntu /home/ubuntu/app

echo "--- One-time setup complete (Docker installed) ---"
echo "--- Application will be deployed via GitHub Actions ---"
echo "--- User Data Script Completed: $(date) ---"
