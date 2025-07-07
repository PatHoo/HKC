/**
 * GCP Terraform HPA 实现 - 变量定义
 * 创建日期: 2025-07-07
 */

variable "project_id" {
  description = "GCP 项目 ID"
  type        = string
}

variable "region" {
  description = "GCP 区域"
  type        = string
  default     = "asia-east1"
}

variable "zone" {
  description = "GCP 可用区"
  type        = string
  default     = "asia-east1-a"
}

variable "cluster_name" {
  description = "GKE 集群名称"
  type        = string
  default     = "gke-hpa-demo"
}

variable "network" {
  description = "VPC 网络名称"
  type        = string
  default     = "default"
}

variable "subnetwork" {
  description = "VPC 子网名称"
  type        = string
  default     = "default"
}

variable "ip_range_pods" {
  description = "Pod IP 地址范围名称"
  type        = string
  default     = "ip-range-pods"
}

variable "ip_range_services" {
  description = "服务 IP 地址范围名称"
  type        = string
  default     = "ip-range-services"
}

variable "node_pools" {
  description = "节点池列表"
  type        = list(map(string))
  default = [
    {
      name               = "default-node-pool"
      machine_type       = "e2-medium"
      min_count          = 1
      max_count          = 3
      disk_size_gb       = 100
      disk_type          = "pd-standard"
      image_type         = "COS_CONTAINERD"
      auto_repair        = true
      auto_upgrade       = true
      preemptible        = false
    }
  ]
}

variable "node_pools_oauth_scopes" {
  description = "节点池的 OAuth 作用域"
  type        = map(list(string))
  default = {
    all = [
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
      "https://www.googleapis.com/auth/devstorage.read_only",
      "https://www.googleapis.com/auth/compute",
    ]
  }
}

variable "node_pools_labels" {
  description = "节点池的标签"
  type        = map(map(string))
  default     = {}
}

variable "node_pools_metadata" {
  description = "节点池的元数据"
  type        = map(map(string))
  default     = {}
}

variable "node_pools_taints" {
  description = "节点池的污点"
  type        = map(list(object({ key = string, value = string, effect = string })))
  default     = {}
}

variable "node_pools_tags" {
  description = "节点池的网络标签"
  type        = map(list(string))
  default     = {}
}

variable "app_name" {
  description = "应用名称"
  type        = string
  default     = "demo-app"
}

variable "app_image" {
  description = "应用容器镜像"
  type        = string
  default     = "nginx:latest"
}

variable "app_replicas" {
  description = "应用初始副本数"
  type        = number
  default     = 2
}

variable "cpu_threshold" {
  description = "HPA CPU 使用率阈值百分比"
  type        = number
  default     = 50
}

variable "min_replicas" {
  description = "HPA 最小副本数"
  type        = number
  default     = 1
}

variable "max_replicas" {
  description = "HPA 最大副本数"
  type        = number
  default     = 10
}
