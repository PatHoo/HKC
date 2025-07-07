/**
 * 代理模块输出定义
 * 创建日期: 2025-07-08
 */

output "instance_id" {
  description = "代理服务器实例 ID"
  value       = google_compute_instance.proxy.id
}

output "instance_name" {
  description = "代理服务器实例名称"
  value       = google_compute_instance.proxy.name
}

output "public_ip" {
  description = "代理服务器公共 IP 地址"
  value       = google_compute_instance.proxy.network_interface[0].access_config[0].nat_ip
}

output "private_ip" {
  description = "代理服务器内部 IP 地址"
  value       = google_compute_instance.proxy.network_interface[0].network_ip
}

output "active_env" {
  description = "当前活动环境"
  value       = var.active_env
}
