#!/bin/bash

set -e

# Initialize Terraform
echo "Initializing Terraform..."
terraform init

# Create var file
arn=$(aws sts get-caller-identity --query Arn --output text)
echo "principal_arn = \"$arn\"" > terraform.tfvars
# Apply Terraform configuration
echo "Applying Terraform configuration..."
terraform apply -auto-approve

# Configure kubectl
echo "Configuring kubectl..."
aws eks update-kubeconfig --region us-east-1 --name sandbox-cluster

# Verify cluster access
echo "Verifying cluster access..."
kubectl get nodes
if [ $? -ne 0 ]; then
  echo "Error: Cannot connect to EKS cluster. Check AWS credentials and cluster endpoint."
  exit 1
fi

# Deploy a test pod
echo "Deploying test pod..."
kubectl run nginx --image=nginx --restart=Never
kubectl get pods

# Save kubeconfig
echo "Saving kubeconfig..."
cp ~/.kube/config ~/sandbox-config
echo "Kubeconfig saved to ~/sandbox-config. Download it for future use."

echo "Setup complete! Test pod deployed. Run 'terraform destroy -auto-approve' to clean up."