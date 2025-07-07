/**
 * tf-hsbc-interview GKE 模块输出
 */

output "cluster_name" {
  description = "GKE 集群名称"
  value       = google_container_cluster.primary.name
}

output "cluster_endpoint" {
  description = "GKE 集群端点"
  value       = google_container_cluster.primary.endpoint
}

output "cluster_ca_certificate" {
  description = "GKE 集群 CA 证书"
  value       = base64decode(google_container_cluster.primary.master_auth.0.cluster_ca_certificate)
  sensitive   = true
}

output "cluster_location" {
  description = "GKE 集群位置"
  value       = google_container_cluster.primary.location
}

output "cluster_self_link" {
  description = "GKE 集群 self link"
  value       = google_container_cluster.primary.self_link
}

output "node_pool_name" {
  description = "GKE 节点池名称"
  value       = google_container_node_pool.primary_nodes.name
}
