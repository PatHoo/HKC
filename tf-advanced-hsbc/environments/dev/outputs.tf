output "gke_cluster_name" {
  description = "The name of the GKE cluster"
  value       = module.gke.cluster_name
}

output "gke_cluster_endpoint" {
  description = "The endpoint for the GKE cluster"
  value       = module.gke.cluster_endpoint
}

output "gke_cluster_ca_certificate" {
  description = "The CA certificate for the GKE cluster"
  value       = module.gke.cluster_ca_cert
  sensitive   = true
}

output "jenkins_url" {
  description = "The URL to access Jenkins"
  value       = module.jenkins.jenkins_url
}

output "hpa_demo_url" {
  description = "The URL to access the HPA demo application"
  value       = module.hpa_demo.app_url
}

output "network_name" {
  description = "The name of the VPC network"
  value       = module.network.network_name
}

output "subnet_names" {
  description = "The names of the subnets"
  value       = module.network.subnet_names
}

output "state_bucket_name" {
  description = "The name of the GCS bucket for Terraform state"
  value       = module.state.bucket_name
}

output "kubeconfig" {
  description = "kubectl config file contents for the GKE cluster"
  value       = module.gke.kubeconfig
  sensitive   = true
}

output "jenkins_admin_username" {
  description = "Jenkins admin username"
  value       = var.jenkins_admin_username
}

output "jenkins_admin_password" {
  description = "Jenkins admin password"
  value       = module.jenkins.jenkins_admin_password
  sensitive   = true
}
