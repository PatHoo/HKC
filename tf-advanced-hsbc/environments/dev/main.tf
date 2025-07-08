# Provider configuration
provider "google" {
  project = var.project_id
  region  = var.region
}

# Remote state configuration
terraform {
  backend "gcs" {
    # This will be replaced by the init script
    bucket = ""
    prefix = "dev/state"
  }
}

# State module for managing remote state
module "state" {
  source = "../../modules/state"
  
  project_id = var.project_id
  region     = var.region
}

# Network module
module "network" {
  source = "../../modules/network"
  
  project_id     = var.project_id
  region         = var.region
  environment    = var.environment
  network_name   = "${var.environment}-vpc"
  subnets = [
    {
      name          = "${var.environment}-subnet-1"
      ip_cidr_range = "10.0.1.0/24"
      region        = var.region
    }
  ]
}

# GKE Cluster module
module "gke" {
  source = "../../modules/gke"
  
  project_id          = var.project_id
  region              = var.region
  environment         = var.environment
  cluster_name        = "${var.environment}-gke-cluster"
  network             = module.network.network_name
  subnetwork          = module.network.subnets[0].name
  master_ipv4_cidr_block = "172.16.0.0/28"
  
  node_pools = [
    {
      name          = "default-node-pool"
      min_count     = 1
      max_count     = 3
      machine_type  = "e2-medium"
      disk_size_gb  = 100
      disk_type     = "pd-standard"
      preemptible   = true
      auto_repair   = true
      auto_upgrade  = true
    }
  ]
}

# Jenkins module
module "jenkins" {
  source = "../../modules/jenkins"
  
  project_id       = var.project_id
  region           = var.region
  environment      = var.environment
  cluster_name     = module.gke.cluster_name
  cluster_endpoint = module.gke.cluster_endpoint
  cluster_ca_cert  = module.gke.cluster_ca_cert
  
  depends_on = [module.gke]
}

# HPA Demo module
module "hpa_demo" {
  source = "../../modules/hpa-demo"
  
  project_id       = var.project_id
  region           = var.region
  environment      = var.environment
  cluster_name     = module.gke.cluster_name
  cluster_endpoint = module.gke.cluster_endpoint
  cluster_ca_cert  = module.gke.cluster_ca_cert
  
  depends_on = [module.gke]
}

# Outputs
output "gke_cluster_name" {
  description = "The name of the GKE cluster"
  value       = module.gke.cluster_name
}

output "jenkins_url" {
  description = "The URL of the Jenkins server"
  value       = module.jenkins.jenkins_url
}

output "hpa_demo_url" {
  description = "The URL of the HPA demo application"
  value       = module.hpa_demo.app_url
}
