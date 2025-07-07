/**
 * 绿环境模块变量定义
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

variable "network" {
  description = "VPC 网络名称"
  type        = string
}

variable "subnetwork" {
  description = "子网名称"
  type        = string
}

variable "app_name" {
  description = "应用名称"
  type        = string
}

variable "app_version" {
  description = "应用版本号"
  type        = string
}

variable "environment" {
  description = "环境名称（green）"
  type        = string
  default     = "green"
}

variable "machine_type" {
  description = "实例类型"
  type        = string
}

variable "port" {
  description = "应用端口"
  type        = number
  default     = 8082
}

variable "deploy_path" {
  description = "应用部署路径"
  type        = string
  default     = "/var/www"
}

variable "is_active" {
  description = "是否为活动环境"
  type        = bool
  default     = false
}
