output "jenkins_ip" {
  description = "Jenkins 服务的外部 IP 地址"
  value       = kubernetes_service.jenkins.status.0.load_balancer.0.ingress.0.ip
}

output "jenkins_url" {
  description = "Jenkins 服务的 URL"
  value       = "http://${kubernetes_service.jenkins.status.0.load_balancer.0.ingress.0.ip}:8080"
}

output "jenkins_namespace" {
  description = "Jenkins 部署的命名空间"
  value       = kubernetes_namespace.jenkins.metadata[0].name
}

output "blue_service_name" {
  description = "蓝色环境服务名称"
  value       = kubernetes_service.jenkins_blue.metadata[0].name
}

output "green_service_name" {
  description = "绿色环境服务名称"
  value       = kubernetes_service.jenkins_green.metadata[0].name
}
