FROM gitpod/workspace-full:latest

USER root

# Install system dependencies
RUN apt-get update && apt-get install -y \
    unzip \
    curl \
    tar \
    python3 \
    gnupg \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Install AWS CLI v2
RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" && \
    unzip awscliv2.zip && \
    ./aws/install && \
    rm -rf awscliv2.zip aws

# Install Terraform
ENV TERRAFORM_VERSION=1.9.2
RUN curl -fsSL https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip -o terraform.zip && \
    unzip terraform.zip && \
    mv terraform /usr/local/bin/ && \
    rm terraform.zip

# ✅ Fixed: Install kubectl
RUN curl -LO "https://dl.k8s.io/release/$(curl -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl" && \
    install -m 0755 kubectl /usr/local/bin && \
    rm kubectl

# Install eksctl
RUN ARCH=amd64 && \
    PLATFORM=linux_$ARCH && \
    curl --silent --location "https://github.com/eksctl-io/eksctl/releases/latest/download/eksctl_${PLATFORM}.tar.gz" | tar xz -C /tmp && \
    mv /tmp/eksctl /usr/local/bin

# Verify installations
RUN terraform -version
RUN aws --version
RUN kubectl version --client
RUN eksctl version

USER gitpod
