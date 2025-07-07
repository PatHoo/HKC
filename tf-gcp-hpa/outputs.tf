/**
 * GCP Terraform HPA 实现 - 输出
 * 创建日期: 2025-07-07
 */

output "cluster_name" {
  description = "GKE 集群名称"
  value       = module.gke.name
}

output "cluster_endpoint" {
  description = "GKE 集群 API 服务器端点"
  value       = module.gke.endpoint
}

output "cluster_ca_certificate" {
  description = "GKE 集群 CA 证书"
  value       = module.gke.ca_certificate
  sensitive   = true
}

output "cluster_location" {
  description = "GKE 集群位置"
  value       = module.gke.location
}

output "app_namespace" {
  description = "应用命名空间"
  value       = module.kubernetes_resources.app_namespace
}

output "app_deployment_name" {
  description = "应用部署名称"
  value       = module.kubernetes_resources.app_deployment_name
}

output "app_service_name" {
  description = "应用服务名称"
  value       = module.kubernetes_resources.app_service_name
}

output "hpa_name" {
  description = "HPA 名称"
  value       = module.kubernetes_resources.hpa_name
}

output "kubectl_connect_command" {
  description = "连接到集群的 kubectl 命令"
  value       = "gcloud container clusters get-credentials ${module.gke.name} --region ${var.region}"
}

output "hpa_status_command" {
  description = "查看 HPA 状态的命令"
  value       = "kubectl get hpa -n ${module.kubernetes_resources.app_namespace} -w"
}

output "load_test_command" {
  description = "生成负载测试 HPA 的命令"
  value       = "kubectl run -i --tty load-generator --rm --image=busybox --restart=Never -- /bin/sh -c \"while sleep 0.01; do wget -q -O- http://${module.kubernetes_resources.app_service_name}.${module.kubernetes_resources.app_namespace}; done\""
}
