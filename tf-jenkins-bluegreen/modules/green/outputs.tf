/**
 * 绿环境模块输出定义
 * 创建日期: 2025-07-08
 */

output "instance_id" {
  description = "绿环境实例 ID"
  value       = google_compute_instance.green.id
}

output "instance_name" {
  description = "绿环境实例名称"
  value       = google_compute_instance.green.name
}

output "instance_address" {
  description = "绿环境实例内部 IP 地址"
  value       = google_compute_instance.green.network_interface[0].network_ip
}

output "public_ip" {
  description = "绿环境实例公共 IP 地址"
  value       = google_compute_instance.green.network_interface[0].access_config[0].nat_ip
}

output "environment" {
  description = "环境名称"
  value       = var.environment
}

output "is_active" {
  description = "是否为活动环境"
  value       = var.is_active
}

output "app_version" {
  description = "应用版本"
  value       = var.app_version
}

output "port" {
  description = "应用端口"
  value       = var.port
}
