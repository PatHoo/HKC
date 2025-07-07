/**
 * GCP Terraform HPA 实现 - 网络模块输出
 * 创建日期: 2025-07-07
 */

output "network_name" {
  description = "VPC 网络名称"
  value       = google_compute_network.vpc.name
}

output "subnetwork_name" {
  description = "子网名称"
  value       = google_compute_subnetwork.subnet.name
}

output "ip_range_pods_name" {
  description = "Pod IP 范围名称"
  value       = var.ip_range_pods_name
}

output "ip_range_services_name" {
  description = "Service IP 范围名称"
  value       = var.ip_range_services_name
}
