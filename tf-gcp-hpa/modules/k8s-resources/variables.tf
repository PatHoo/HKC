/**
 * GCP Terraform HPA 实现 - Kubernetes 资源模块变量
 * 创建日期: 2025-07-07
 */

variable "app_name" {
  description = "应用名称"
  type        = string
}

variable "app_image" {
  description = "应用容器镜像"
  type        = string
}

variable "app_replicas" {
  description = "应用初始副本数"
  type        = number
}

variable "cpu_threshold" {
  description = "HPA CPU 使用率阈值百分比"
  type        = number
}

variable "min_replicas" {
  description = "HPA 最小副本数"
  type        = number
}

variable "max_replicas" {
  description = "HPA 最大副本数"
  type        = number
}
