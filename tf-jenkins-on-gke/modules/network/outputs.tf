/**
 * tf-jenkins-on-gke 网络模块输出
 */

output "network_name" {
  description = "VPC 网络名称"
  value       = google_compute_network.vpc.name
}

output "network_self_link" {
  description = "VPC 网络自链接"
  value       = google_compute_network.vpc.self_link
}

output "subnet_name" {
  description = "子网名称"
  value       = google_compute_subnetwork.subnet.name
}

output "subnet_self_link" {
  description = "子网自链接"
  value       = google_compute_subnetwork.subnet.self_link
}

output "ip_range_pods_name" {
  description = "GKE Pod IP 范围名称"
  value       = var.ip_range_pods_name
}

output "ip_range_services_name" {
  description = "GKE 服务 IP 范围名称"
  value       = var.ip_range_services_name
}
