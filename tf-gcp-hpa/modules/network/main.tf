/**
 * GCP Terraform HPA 实现 - 网络模块
 * 创建日期: 2025-07-07
 */

# 创建 VPC 网络
resource "google_compute_network" "vpc" {
  name                    = var.network_name
  auto_create_subnetworks = false
  project                 = var.project_id
}

# 创建子网
resource "google_compute_subnetwork" "subnet" {
  name          = var.subnetwork_name
  region        = var.region
  network       = google_compute_network.vpc.name
  ip_cidr_range = var.subnet_ip_cidr_range
  project       = var.project_id

  # 创建次要 IP 范围
  secondary_ip_range {
    range_name    = var.ip_range_pods_name
    ip_cidr_range = var.ip_range_pods_cidr
  }

  secondary_ip_range {
    range_name    = var.ip_range_services_name
    ip_cidr_range = var.ip_range_services_cidr
  }

  # 启用私有 Google 访问
  private_ip_google_access = true
}
