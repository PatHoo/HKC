/**
 * GCP Terraform HPA 实现 - Kubernetes 资源模块输出
 * 创建日期: 2025-07-07
 */

output "app_namespace" {
  description = "应用命名空间"
  value       = kubernetes_namespace.app_namespace.metadata[0].name
}

output "app_deployment_name" {
  description = "应用部署名称"
  value       = kubernetes_deployment.app.metadata[0].name
}

output "app_service_name" {
  description = "应用服务名称"
  value       = kubernetes_service.app.metadata[0].name
}

output "hpa_name" {
  description = "HPA 名称"
  value       = kubernetes_horizontal_pod_autoscaler_v2.app.metadata[0].name
}

output "min_replicas" {
  description = "HPA 最小副本数"
  value       = kubernetes_horizontal_pod_autoscaler_v2.app.spec[0].min_replicas
}

output "max_replicas" {
  description = "HPA 最大副本数"
  value       = kubernetes_horizontal_pod_autoscaler_v2.app.spec[0].max_replicas
}

output "cpu_threshold" {
  description = "HPA CPU 使用率阈值百分比"
  value       = kubernetes_horizontal_pod_autoscaler_v2.app.spec[0].metric[0].resource[0].target[0].average_utilization
}
