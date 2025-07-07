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

# 创建 GKE 集群
module "gke" {
  source                     = "./modules/gke"
  project_id                 = var.project_id
  cluster_name               = var.cluster_name
  region                     = var.region
  network                    = var.network
  subnetwork                 = var.subnetwork
  ip_range_pods              = var.ip_range_pods
  ip_range_services          = var.ip_range_services
  node_pools                 = var.node_pools
  node_pools_oauth_scopes    = var.node_pools_oauth_scopes
  node_pools_labels          = var.node_pools_labels
  node_pools_metadata        = var.node_pools_metadata
  node_pools_taints          = var.node_pools_taints
  node_pools_tags            = var.node_pools_tags
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
