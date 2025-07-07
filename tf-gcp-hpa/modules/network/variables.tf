/**
 * GCP Terraform HPA 实现 - 网络模块变量
 * 创建日期: 2025-07-07
 */

variable "project_id" {
  description = "GCP 项目 ID"
  type        = string
}

variable "region" {
  description = "GCP 区域"
  type        = string
}

variable "network_name" {
  description = "VPC 网络名称"
  type        = string
  default     = "gke-network"
}

variable "subnetwork_name" {
  description = "子网名称"
  type        = string
  default     = "gke-subnet"
}

variable "subnet_ip_cidr_range" {
  description = "子网 IP CIDR 范围"
  type        = string
  default     = "10.0.0.0/20"
}

variable "ip_range_pods_name" {
  description = "Pod IP 范围名称"
  type        = string
  default     = "ip-range-pods"
}

variable "ip_range_pods_cidr" {
  description = "Pod IP CIDR 范围"
  type        = string
  default     = "10.1.0.0/16"
}

variable "ip_range_services_name" {
  description = "Service IP 范围名称"
  type        = string
  default     = "ip-range-services"
}

variable "ip_range_services_cidr" {
  description = "Service IP CIDR 范围"
  type        = string
  default     = "10.2.0.0/20"
}
