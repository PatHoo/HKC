# HKC
Terraform for GCP

## Subprojects

This repository contains the following subprojects:

1. **tf-gcp-hpa** - Implementing Kubernetes Horizontal Pod Autoscaler (HPA) on GCP using Terraform
   - Creates a GKE cluster
   - Deploys a sample application
   - Configures HPA for automatic scaling
   - Supports scaling based on CPU and memory utilization
   - [View Architecture Diagram](./tf-gcp-hpa/README_EN.md#architecture-diagram)

2. **tf-jenkins-bluegreen** - Simple Blue/Green Deployment implementation on Jenkins
   - Complete Jenkins pipeline
   - Automated deployment, testing, and switching process
   - One-click rollback support
   - Nginx-based traffic switching
   - [View Architecture Diagram](./tf-jenkins-bluegreen/README_EN.md#architecture-diagram)

## Usage Instructions

Each subproject has its own README.md file containing detailed usage instructions and configuration guidelines. Please refer to the documentation in each subproject directory.
