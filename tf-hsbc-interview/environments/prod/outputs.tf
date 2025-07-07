/**
 * tf-hsbc-interview 生产环境输出
 */

# 网络输出
output "network_name" {
  description = "VPC 网络名称"
  value       = module.network.network_name
}

output "subnet_name" {
  description = "子网名称"
  value       = module.network.subnet_name
}

# GKE 集群输出
output "cluster_name" {
  description = "GKE 集群名称"
  value       = module.gke.cluster_name
}

output "cluster_endpoint" {
  description = "GKE 集群端点"
  value       = module.gke.cluster_endpoint
}

# Jenkins 输出
output "jenkins_namespace" {
  description = "Jenkins 命名空间"
  value       = module.jenkins.jenkins_namespace
}

output "jenkins_url" {
  description = "Jenkins URL"
  value       = module.jenkins.jenkins_url
}

# HPA 演示输出
output "hpa_demo_namespace" {
  description = "HPA 演示命名空间"
  value       = module.hpa_demo.namespace
}

output "hpa_demo_url" {
  description = "HPA 演示应用 URL"
  value       = module.hpa_demo.app_url
}
