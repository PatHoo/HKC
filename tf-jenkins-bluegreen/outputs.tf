/**
 * GCP Terraform 蓝绿部署输出定义
 * 创建日期: 2025-07-08
 */

# 代理服务器公共 IP
output "proxy_public_ip" {
  description = "代理服务器公共 IP 地址"
  value       = module.proxy.public_ip
}

# 当前活动环境
output "active_environment" {
  description = "当前活动环境（蓝或绿）"
  value       = var.active_env
}

# 蓝环境实例 IP
output "blue_instance_ip" {
  description = "蓝环境实例 IP 地址"
  value       = module.blue.instance_address
}

# 绿环境实例 IP
output "green_instance_ip" {
  description = "绿环境实例 IP 地址"
  value       = module.green.instance_address
}

# 应用版本
output "app_version" {
  description = "当前部署的应用版本"
  value       = var.app_version
}

# 应用 URL
output "app_url" {
  description = "应用访问 URL"
  value       = "http://${module.proxy.public_ip}"
}
