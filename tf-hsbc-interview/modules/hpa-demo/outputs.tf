/**
 * tf-hsbc-interview HPA 演示模块输出
 */

output "namespace" {
  description = "HPA 演示应用命名空间"
  value       = kubernetes_namespace.hpa_demo.metadata[0].name
}

output "deployment_name" {
  description = "HPA 演示应用部署名称"
  value       = kubernetes_deployment.hpa_demo.metadata[0].name
}

output "service_name" {
  description = "HPA 演示应用服务名称"
  value       = kubernetes_service.hpa_demo.metadata[0].name
}

output "service_ip" {
  description = "HPA 演示应用服务 IP (如果是 LoadBalancer 类型)"
  value       = kubernetes_service.hpa_demo.status.0.load_balancer.0.ingress.0.ip
}

output "hpa_name" {
  description = "HPA 名称"
  value       = kubernetes_horizontal_pod_autoscaler_v2.hpa_demo.metadata[0].name
}

output "app_url" {
  description = "应用 URL"
  value       = "http://${kubernetes_service.hpa_demo.status.0.load_balancer.0.ingress.0.ip}"
}
