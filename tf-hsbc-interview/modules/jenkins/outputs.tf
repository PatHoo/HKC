/**
 * tf-hsbc-interview Jenkins 模块输出
 */

output "jenkins_namespace" {
  description = "Jenkins 命名空间"
  value       = kubernetes_namespace.jenkins.metadata[0].name
}

output "jenkins_service_name" {
  description = "Jenkins 服务名称"
  value       = kubernetes_service.jenkins.metadata[0].name
}

output "jenkins_service_ip" {
  description = "Jenkins 服务 IP (如果是 LoadBalancer 类型)"
  value       = kubernetes_service.jenkins.status.0.load_balancer.0.ingress.0.ip
}

output "jenkins_service_port" {
  description = "Jenkins 服务端口"
  value       = kubernetes_service.jenkins.spec[0].port[0].port
}

output "jenkins_url" {
  description = "Jenkins URL"
  value       = "http://${kubernetes_service.jenkins.status.0.load_balancer.0.ingress.0.ip}:${kubernetes_service.jenkins.spec[0].port[0].port}"
}
