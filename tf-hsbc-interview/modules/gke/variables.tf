/**
 * tf-hsbc-interview GKE 模块变量
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

variable "cluster_name" {
  description = "GKE 集群名称"
  type        = string
  default     = "hsbc-demo-cluster"
}

variable "network_self_link" {
  description = "VPC 网络 self link"
  type        = string
}

variable "subnet_self_link" {
  description = "子网 self link"
  type        = string
}

variable "ip_range_pods_name" {
  description = "GKE Pods IP 范围名称"
  type        = string
}

variable "ip_range_services_name" {
  description = "GKE Services IP 范围名称"
  type        = string
}

variable "enable_private_nodes" {
  description = "是否启用私有节点"
  type        = bool
  default     = true
}

variable "enable_private_endpoint" {
  description = "是否启用私有端点"
  type        = bool
  default     = false
}

variable "master_ipv4_cidr_block" {
  description = "GKE 主节点 IP CIDR 块"
  type        = string
  default     = "172.16.0.0/28"
}

variable "node_count" {
  description = "每个区域的节点数量"
  type        = number
  default     = 1
}

variable "min_node_count" {
  description = "自动缩放的最小节点数"
  type        = number
  default     = 1
}

variable "max_node_count" {
  description = "自动缩放的最大节点数"
  type        = number
  default     = 5
}

variable "machine_type" {
  description = "节点机器类型"
  type        = string
  default     = "e2-standard-2"
}

variable "disk_size_gb" {
  description = "节点磁盘大小 (GB)"
  type        = number
  default     = 100
}

variable "disk_type" {
  description = "节点磁盘类型"
  type        = string
  default     = "pd-standard"
}

variable "preemptible" {
  description = "是否使用抢占式虚拟机"
  type        = bool
  default     = false
}

variable "deletion_protection" {
  description = "是否启用集群删除保护"
  type        = bool
  default     = true
}
