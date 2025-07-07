# tf-hsbc-interview

This is a Terraform project for HSBC interview demonstration, showcasing how to use Terraform to automate the deployment of Kubernetes clusters, Jenkins blue/green deployments, and HPA (Horizontal Pod Autoscaling) functionality.

## Architecture Diagram

```mermaid
graph TD
    subgraph "Google Cloud Platform"
        subgraph "VPC Network"
            NET[Network Module] --> SUBNET[Subnet Configuration]
            SUBNET --> POD_RANGE[Pod IP Range]
            SUBNET --> SVC_RANGE[Service IP Range]
            NET --> FW[Firewall Rules]
        end

        subgraph "GKE Cluster"
            GKE[GKE Module] --> NODE_POOL[Node Pool]
            GKE --> CLUSTER_CONFIG[Cluster Configuration]
            CLUSTER_CONFIG --> PRIVATE[Private Cluster Settings]
            CLUSTER_CONFIG --> AUTOSCALE[Cluster Autoscaling]
        end

        subgraph "Kubernetes Resources"
            subgraph "Jenkins Deployment"
                JENKINS[Jenkins Module] --> BLUE[Blue Deployment]
                JENKINS --> GREEN[Green Deployment]
                BLUE --> SWITCH{Traffic Switch}
                GREEN --> SWITCH
                SWITCH --> SVC[Jenkins Service]
            end

            subgraph "HPA Demo"
                HPA_DEMO[HPA Demo Module] --> APP[Sample Application]
                APP --> HPA[Horizontal Pod Autoscaling]
                HPA --> METRICS[CPU/Memory Metrics]
            end
        end
    end

    ENV_DEV[Development Environment] --> NET
    ENV_DEV --> GKE
    ENV_DEV --> JENKINS
    ENV_DEV --> HPA_DEMO

    ENV_PROD[Production Environment] --> NET
    ENV_PROD --> GKE
    ENV_PROD --> JENKINS
    ENV_PROD --> HPA_DEMO

    SCRIPTS[Switch Scripts] -.-> SWITCH
```

## Project Structure

```
tf-hsbc-interview/
├── environments/           # Environment-specific configurations
│   ├── dev/                # Development environment
│   └── prod/               # Production environment
├── modules/                # Reusable modules
│   ├── blue-green/         # Blue/Green deployment module
│   ├── gke/                # Google Kubernetes Engine module
│   ├── hpa-demo/           # HPA demonstration application module
│   ├── jenkins/            # Jenkins module
│   └── network/            # Network module
└── scripts/                # Helper scripts
```

## Features

1. **Custom Network Configuration**: Create VPC networks, subnets, and firewall rules
2. **GKE Cluster Deployment**: Configure and deploy Google Kubernetes Engine clusters
3. **Jenkins Deployment**: Deploy Jenkins on Kubernetes
4. **Blue/Green Deployment**: Implement blue/green deployment strategy for Jenkins
5. **HPA Demonstration**: Showcase Kubernetes Horizontal Pod Autoscaling functionality

## Component Relationship Diagram

```mermaid
flowchart LR
    subgraph Terraform
        TF[Terraform Configuration] --> MODULES[Modules]
        TF --> ENVS[Environment Configurations]
    end
    
    subgraph Modules
        MODULES --> NET_MOD[Network Module]
        MODULES --> GKE_MOD[GKE Module]
        MODULES --> JENKINS_MOD[Jenkins Module]
        MODULES --> HPA_MOD[HPA Demo Module]
    end
    
    subgraph Environments
        ENVS --> DEV[Development Environment]
        ENVS --> PROD[Production Environment]
    end
    
    subgraph Infrastructure
        NET_MOD --> VPC[VPC Network]
        GKE_MOD --> CLUSTER[GKE Cluster]
    end
    
    subgraph Kubernetes
        CLUSTER --> JENKINS_NS[Jenkins Namespace]
        CLUSTER --> HPA_NS[HPA Demo Namespace]
        
        JENKINS_NS --> JENKINS_BLUE[Jenkins Blue Deployment]
        JENKINS_NS --> JENKINS_GREEN[Jenkins Green Deployment]
        JENKINS_NS --> JENKINS_SVC[Jenkins Service]
        
        HPA_NS --> DEMO_APP[Demo Application]
        HPA_NS --> HPA_RESOURCE[HPA Resource]
        HPA_NS --> DEMO_SVC[Demo Application Service]
    end
    
    JENKINS_MOD --> JENKINS_NS
    HPA_MOD --> HPA_NS
    
    JENKINS_BLUE --> JENKINS_SVC
    JENKINS_GREEN --> JENKINS_SVC
    DEMO_APP --> HPA_RESOURCE
    DEMO_APP --> DEMO_SVC
```

## Prerequisites

- Google Cloud Platform account
- Terraform v1.0.0+ installed
- Google Cloud SDK installed
- GCP authentication configured

## Usage

### Initialize the Project

```bash
# Change to the development environment directory
cd environments/dev

# Initialize Terraform
terraform init
```

### Deploy Infrastructure

```bash
# Create execution plan
terraform plan -var="project_id=YOUR_GCP_PROJECT_ID" -out=plan.out

# Apply execution plan
terraform apply plan.out
```

### Switch Blue/Green Deployment

```bash
# Switch to green deployment
terraform apply -var="project_id=YOUR_GCP_PROJECT_ID" -var="blue_deployment_active=false"

# Switch back to blue deployment
terraform apply -var="project_id=YOUR_GCP_PROJECT_ID" -var="blue_deployment_active=true"
```

### Test HPA

After deployment, you can test the HPA functionality with the following steps:

1. Get the URL of the HPA demo application
```bash
terraform output hpa_demo_url
```

2. Send requests to the application using a load testing tool (e.g., Apache Bench)
```bash
ab -n 1000 -c 100 http://HPA_DEMO_URL/
```

3. Observe Pod autoscaling
```bash
kubectl get hpa -n dev-hpa-demo -w
```

### Customizing Network

This project supports customizing network configuration through multiple methods:

#### 1. Using terraform.tfvars File

Create a `terraform.tfvars` file in the environment directory (e.g., `environments/dev` or `environments/prod`) and add the following variables:

```hcl
# Network configuration
network_name          = "custom-hsbc-vpc"
subnet_name           = "custom-hsbc-subnet"
subnet_ip_cidr_range  = "10.0.0.0/20"  # Custom subnet CIDR
ip_range_pods_cidr     = "10.10.0.0/16"  # Custom Pod IP range
ip_range_services_cidr = "10.20.0.0/16"  # Custom Service IP range
```

The project root directory provides a `terraform.tfvars.example` sample file that you can copy to the appropriate environment directory and modify as needed:

```bash
# Copy to development environment
copy terraform.tfvars.example environments\dev\terraform.tfvars

# Copy to production environment
copy terraform.tfvars.example environments\prod\terraform.tfvars
```

#### 2. Using Command Line Parameters

Pass variables through the `-var` parameter when executing `terraform apply`:

```bash
terraform apply \
  -var="project_id=YOUR_GCP_PROJECT_ID" \
  -var="network_name=custom-hsbc-vpc" \
  -var="subnet_ip_cidr_range=10.0.0.0/20" \
  -var="ip_range_pods_cidr=10.10.0.0/16" \
  -var="ip_range_services_cidr=10.20.0.0/16"
```

#### 3. Customizable Network Parameters

| Parameter | Description | Default Value |
|------|------|--------|
| `network_name` | VPC network name | `hsbc-demo-vpc` |
| `subnet_name` | Subnet name | `hsbc-demo-subnet` |
| `subnet_ip_cidr_range` | Subnet IP CIDR range | `10.0.0.0/24` |
| `ip_range_pods_name` | GKE Pods IP range name | `ip-range-pods` |
| `ip_range_pods_cidr` | GKE Pods IP CIDR range | `10.1.0.0/16` |
| `ip_range_services_name` | GKE Services IP range name | `ip-range-services` |
| `ip_range_services_cidr` | GKE Services IP CIDR range | `10.2.0.0/16` |
| `region` | GCP region | `asia-east1` |

#### 4. Advanced Customization

For more complex network configurations, you can directly modify the `modules/network/main.tf` file, such as adding more firewall rules, configuring VPC peering connections, setting up NAT gateways, etc.

## Module Descriptions

### Network Module

Creates VPC networks, subnets, and firewall rules to support the network requirements of GKE clusters.

### GKE Module

Configures and deploys Google Kubernetes Engine clusters, including node pools, autoscaling, and security settings.

### Jenkins Module

Deploys Jenkins on Kubernetes and supports blue/green deployment strategy.

### HPA Demo Module

Deploys a sample application and configures HPA to demonstrate Kubernetes Horizontal Pod Autoscaling functionality.

## Notes

- Ensure that the following necessary APIs are enabled in your GCP project:
  - Compute Engine API (`compute.googleapis.com`)
  - Kubernetes Engine API (`container.googleapis.com`)
  - Container Registry API (`containerregistry.googleapis.com`)
  - Cloud Resource Manager API (`cloudresourcemanager.googleapis.com`)
  - Identity and Access Management (IAM) API (`iam.googleapis.com`)
  - Cloud Monitoring API (`monitoring.googleapis.com`)
  - Cloud Logging API (`logging.googleapis.com`)
  - Service Networking API (`servicenetworking.googleapis.com`)
  - Cloud DNS API (`dns.googleapis.com`)
  - Artifact Registry API (`artifactregistry.googleapis.com`)
- Adjust parameters in the variable files according to your actual requirements
- Ensure thorough testing before deploying to production environments
