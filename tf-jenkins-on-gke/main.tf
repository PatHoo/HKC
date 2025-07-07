/**
 * tf-jenkins-on-gke 主配置文件
 * 创建日期: 2025-07-08
 */

terraform {
  required_version = ">= 0.14"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 4.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.0"
    }
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
}

provider "kubernetes" {
  host                   = "https://${module.gke.endpoint}"
  token                  = data.google_client_config.default.access_token
  cluster_ca_certificate = base64decode(module.gke.ca_certificate)
}

provider "helm" {
  kubernetes {
    host                   = "https://${module.gke.endpoint}"
    token                  = data.google_client_config.default.access_token
    cluster_ca_certificate = base64decode(module.gke.ca_certificate)
  }
}

data "google_client_config" "default" {}

# 创建网络资源
module "network" {
  source               = "./modules/network"
  project_id           = var.project_id
  region               = var.region
  network_name         = var.network_name
  subnet_name          = var.subnet_name
  subnet_ip_cidr_range = var.subnet_ip_cidr_range
  ip_range_pods_name   = var.ip_range_pods_name
  ip_range_pods_cidr   = var.ip_range_pods_cidr
  ip_range_services_name = var.ip_range_services_name
  ip_range_services_cidr = var.ip_range_services_cidr
}

# 创建 GKE 集群
module "gke" {
  source       = "./modules/gke"
  project_id   = var.project_id
  region       = var.region
  zone         = var.zone
  name         = var.cluster_name
  node_count   = var.node_count
  machine_type = var.machine_type
  
  # 使用网络模块创建的网络资源
  network      = module.network.network_self_link
  subnetwork   = module.network.subnet_self_link
  
  depends_on   = [module.network]
}

# 部署 Jenkins
module "jenkins" {
  source       = "./modules/jenkins"
  project_id   = var.project_id
  cluster_name = module.gke.name
  namespace    = var.jenkins_namespace
  depends_on   = [module.gke]
}
