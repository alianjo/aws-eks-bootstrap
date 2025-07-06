
# AWS EKS Terraform Sandbox

This repository contains a Terraform configuration to set up an AWS EKS cluster with a VPC, subnets, AWS Load Balancer Controller, NGINX Ingress Controller, and External DNS.

## Prerequisites
- Terraform
- aws cli
- aws account

## Setup with Gitpod
1. **Configure AWS Credentials**:
   - In the Gitpod terminal, run:
     ```bash
     aws configure
     ```
   - Enter the AWS Access Key ID, Secret Access Key, and region (e.g., `us-west-2`) from your account.

2. **Apply Terraform Configuration**:
   ```bash
   terraform init
   terraform apply -auto-approve
   ```
   This creates the VPC, EKS cluster, and installs controllers (~20-25 minutes).

3. **Configure kubectl**:
   ```bash
   aws eks update-kubeconfig --region us-west-2 --name sandbox-cluster
   ```

4. **Verify Setup**:
   ```bash
   kubectl get nodes
   kubectl get deployment -n kube-system aws-load-balancer-controller
   kubectl get deployment -n ingress-nginx
   kubectl get deployment -n kube-system external-dns
   ```

5. **Test with a Sample App**:
   ```bash
   kubectl apply -f https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/v2.7.2/docs/examples/2048/2048_full.yaml
   kubectl get ingress -n game-2048
   ```

## Cleanup
To destroy resources and avoid conflicts:
```bash
terraform destroy -auto-approve
```

## Files
- `main.tf`: Defines VPC and EKS cluster.
- `iam.tf`: Configures IAM roles for controllers.
- `helm.tf`: Installs AWS Load Balancer, NGINX Ingress, and External DNS controllers.
- `iam-policy.json`: IAM policy for AWS Load Balancer Controller.
- `.gitpod.yml`: Configures Gitpod environment.
- `.gitignore`: Excludes temporary and sensitive files.

## Notes
- Save this repository and `~/.kube/config` for reuse.