output "endpoint" {
  description = "GKE集群端点"
  value       = google_container_cluster.primary.endpoint
}

output "ca_certificate" {
  description = "GKE集群CA证书"
  value       = google_container_cluster.primary.master_auth.0.cluster_ca_certificate
  sensitive   = true
}

output "name" {
  description = "GKE集群名称"
  value       = google_container_cluster.primary.name
}

output "location" {
  description = "GKE集群位置"
  value       = google_container_cluster.primary.location
}

output "node_pool_name" {
  description = "GKE节点池名称"
  value       = google_container_node_pool.primary_nodes.name
}
