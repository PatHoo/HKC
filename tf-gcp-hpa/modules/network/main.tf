/**
 * GCP Terraform HPA 实现 - 网络模块
 * 创建日期: 2025-07-07
 * 更新日期: 2025-07-08 (统一变量风格)
 */

# 创建 VPC 网络
resource "google_compute_network" "vpc" {
  name                    = var.network_name
  auto_create_subnetworks = false
  project                 = var.project_id
  description             = "VPC 网络用于 GKE HPA 测试"
}

# 创建子网
resource "google_compute_subnetwork" "subnet" {
  name          = var.subnet_name
  region        = var.region
  network       = google_compute_network.vpc.self_link
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

# 创建防火墙规则允许内部通信
resource "google_compute_firewall" "internal" {
  name    = "${var.network_name}-allow-internal"
  project = var.project_id
  network = google_compute_network.vpc.name

  allow {
    protocol = "icmp"
  }

  allow {
    protocol = "tcp"
  }

  allow {
    protocol = "udp"
  }

  source_ranges = [var.subnet_ip_cidr_range]
}

# 创建防火墙规则允许 SSH 访问
resource "google_compute_firewall" "ssh" {
  name    = "${var.network_name}-allow-ssh"
  project = var.project_id
  network = google_compute_network.vpc.name

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["0.0.0.0/0"]
}

# 创建防火墙规则允许 HTTP/HTTPS 访问
resource "google_compute_firewall" "http" {
  name    = "${var.network_name}-allow-http"
  project = var.project_id
  network = google_compute_network.vpc.name

  allow {
    protocol = "tcp"
    ports    = ["80", "443", "8080"]
  }

  source_ranges = ["0.0.0.0/0"]
}
