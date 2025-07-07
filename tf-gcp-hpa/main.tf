/**
 * GCP Terraform HPA 实现
 * 创建日期: 2025-07-07
 */

# 配置 Terraform Google 提供商
terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 4.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.0"
    }
  }
}

# 定义 Google 提供商配置
provider "google" {
  project = var.project_id
  region  = var.region
  zone    = var.zone
}

# 配置 Kubernetes 提供商
provider "kubernetes" {
  host                   = "https://${module.gke.endpoint}"
  token                  = data.google_client_config.default.access_token
  cluster_ca_certificate = base64decode(module.gke.ca_certificate)
}

# 获取 Google 客户端配置
data "google_client_config" "default" {}

# 创建 VPC 网络和子网
module "network" {
  source           = "./modules/network"
  project_id       = var.project_id
  region           = var.region
  network_name     = var.network_name
  subnetwork_name  = var.subnetwork_name
  subnet_ip_cidr_range = var.subnet_ip_cidr_range
  ip_range_pods_name = var.ip_range_pods
  ip_range_pods_cidr = var.ip_range_pods_cidr
  ip_range_services_name = var.ip_range_services
  ip_range_services_cidr = var.ip_range_services_cidr
}

# 创建 GKE 集群
module "gke" {
  source                     = "./modules/gke"
  project_id                 = var.project_id
  cluster_name               = var.cluster_name
  region                     = var.region
  network                    = module.network.network_name
  subnetwork                 = module.network.subnetwork_name
  ip_range_pods              = module.network.ip_range_pods_name
  ip_range_services          = module.network.ip_range_services_name
  node_pools                 = var.node_pools
  node_pools_oauth_scopes    = var.node_pools_oauth_scopes
  node_pools_labels          = var.node_pools_labels
  node_pools_metadata        = var.node_pools_metadata
  node_pools_taints          = var.node_pools_taints
  node_pools_tags            = var.node_pools_tags
  depends_on                 = [module.network]
}

# 部署示例应用和 HPA
module "kubernetes_resources" {
  source       = "./modules/k8s-resources"
  depends_on   = [module.gke]
  app_name     = var.app_name
  app_image    = var.app_image
  app_replicas = var.app_replicas
  cpu_threshold = var.cpu_threshold
  min_replicas  = var.min_replicas
  max_replicas  = var.max_replicas
}
