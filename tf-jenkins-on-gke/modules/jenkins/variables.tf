variable "project_id" {
  description = "GCP项目ID"
  type        = string
}

variable "cluster_name" {
  description = "GKE集群名称"
  type        = string
}

variable "namespace" {
  description = "Jenkins部署的Kubernetes命名空间"
  type        = string
  default     = "jenkins"
}
