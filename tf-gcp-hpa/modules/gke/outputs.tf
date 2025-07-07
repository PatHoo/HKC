/**
 * GCP Terraform HPA 实现 - GKE 模块输出
 * 创建日期: 2025-07-07
 */

output "cluster_id" {
  description = "GKE 集群 ID"
  value       = google_container_cluster.primary.id
}

output "name" {
  description = "GKE 集群名称"
  value       = google_container_cluster.primary.name
}

output "endpoint" {
  description = "GKE 集群 API 服务器端点"
  value       = google_container_cluster.primary.endpoint
}

output "ca_certificate" {
  description = "GKE 集群 CA 证书"
  value       = google_container_cluster.primary.master_auth.0.cluster_ca_certificate
  sensitive   = true
}

output "location" {
  description = "GKE 集群位置"
  value       = google_container_cluster.primary.location
}

output "master_version" {
  description = "GKE 集群主版本"
  value       = google_container_cluster.primary.master_version
}
