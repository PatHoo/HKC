/**
 * tf-jenkins-on-gke 网络模块
 * 创建 VPC 网络、子网和防火墙规则
 */

resource "google_compute_network" "vpc" {
  name                    = var.network_name
  project                 = var.project_id
  auto_create_subnetworks = false
  description             = "VPC 网络用于 Jenkins GKE 集群"
}

resource "google_compute_subnetwork" "subnet" {
  name          = var.subnet_name
  project       = var.project_id
  region        = var.region
  network       = google_compute_network.vpc.self_link
  ip_cidr_range = var.subnet_ip_cidr_range

  # 配置辅助 IP 范围用于 GKE Pods 和 Services
  secondary_ip_range {
    range_name    = var.ip_range_pods_name
    ip_cidr_range = var.ip_range_pods_cidr
  }

  secondary_ip_range {
    range_name    = var.ip_range_services_name
    ip_cidr_range = var.ip_range_services_cidr
  }

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
