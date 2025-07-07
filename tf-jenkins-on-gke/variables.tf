/**
 * tf-jenkins-on-gke 变量定义文件
 * 创建日期: 2025-07-08
 */

# GCP 项目配置
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

# 网络配置
variable "network_name" {
  description = "VPC 网络名称"
  type        = string
  default     = "jenkins-network"
}

variable "subnet_name" {
  description = "子网名称"
  type        = string
  default     = "jenkins-subnet"
}

variable "subnet_ip_cidr_range" {
  description = "子网 IP CIDR 范围"
  type        = string
  default     = "10.0.0.0/20"
}

variable "ip_range_pods_name" {
  description = "GKE Pod IP 范围名称"
  type        = string
  default     = "ip-range-pods"
}

variable "ip_range_pods_cidr" {
  description = "GKE Pod IP CIDR 范围"
  type        = string
  default     = "10.16.0.0/16"
}

variable "ip_range_services_name" {
  description = "GKE 服务 IP 范围名称"
  type        = string
  default     = "ip-range-services"
}

variable "ip_range_services_cidr" {
  description = "GKE 服务 IP CIDR 范围"
  type        = string
  default     = "10.20.0.0/16"
}

# GKE 集群配置
variable "cluster_name" {
  description = "GKE 集群名称"
  type        = string
  default     = "jenkins-cluster"
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

# Jenkins 配置
variable "jenkins_namespace" {
  description = "Jenkins 部署的 Kubernetes 命名空间"
  type        = string
  default     = "jenkins"
}
