/**
 * GCP Terraform HPA 实现 - GKE 模块变量
 * 创建日期: 2025-07-07
 */

variable "project_id" {
  description = "GCP 项目 ID"
  type        = string
}

variable "cluster_name" {
  description = "GKE 集群名称"
  type        = string
}

variable "region" {
  description = "GCP 区域"
  type        = string
}

variable "network" {
  description = "VPC 网络名称"
  type        = string
}

variable "subnetwork" {
  description = "VPC 子网名称"
  type        = string
}

variable "ip_range_pods" {
  description = "Pod IP 地址范围名称"
  type        = string
}

variable "ip_range_services" {
  description = "服务 IP 地址范围名称"
  type        = string
}

variable "node_pools" {
  description = "节点池列表"
  type        = list(map(string))
}

variable "node_pools_oauth_scopes" {
  description = "节点池的 OAuth 作用域"
  type        = map(list(string))
}

variable "node_pools_labels" {
  description = "节点池的标签"
  type        = map(map(string))
}

variable "node_pools_metadata" {
  description = "节点池的元数据"
  type        = map(map(string))
}

variable "node_pools_taints" {
  description = "节点池的污点"
  type        = map(list(object({ key = string, value = string, effect = string })))
}

variable "node_pools_tags" {
  description = "节点池的网络标签"
  type        = map(list(string))
}
