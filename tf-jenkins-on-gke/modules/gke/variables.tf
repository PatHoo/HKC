/**
 * tf-jenkins-on-gke GKE 模块变量定义
 * 创建日期: 2025-07-08
 */

variable "project_id" {
  description = "GCP 项目 ID"
  type        = string
}

variable "region" {
  description = "GCP 区域"
  type        = string
}

variable "zone" {
  description = "GCP 可用区"
  type        = string
}

variable "name" {
  description = "GKE 集群名称"
  type        = string
}

variable "node_count" {
  description = "每个节点池的节点数量"
  type        = number
  default     = 3
}

variable "machine_type" {
  description = "GKE 节点机器类型"
  type        = string
  default     = "e2-standard-2"
}

variable "network" {
  description = "VPC 网络自链接"
  type        = string
}

variable "subnetwork" {
  description = "VPC 子网自链接"
  type        = string
}
