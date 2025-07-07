/**
 * GCP Terraform 蓝绿部署变量定义
 * 创建日期: 2025-07-08
 */

# 项目基础配置
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
variable "network" {
  description = "VPC 网络名称"
  type        = string
  default     = "default"
}

variable "subnetwork" {
  description = "子网名称"
  type        = string
  default     = "default"
}

# 应用配置
variable "app_name" {
  description = "应用名称"
  type        = string
  default     = "demo-app"
}

variable "app_version" {
  description = "应用版本号"
  type        = string
  default     = "1.0.0"
}

variable "previous_version" {
  description = "上一个应用版本号"
  type        = string
  default     = "0.9.0"
}

# 环境配置
variable "active_env" {
  description = "当前活动环境（blue 或 green）"
  type        = string
  default     = "blue"
  validation {
    condition     = var.active_env == "blue" || var.active_env == "green"
    error_message = "活动环境必须是 'blue' 或 'green'。"
  }
}

# 实例配置
variable "machine_type" {
  description = "应用实例类型"
  type        = string
  default     = "e2-medium"
}

variable "proxy_machine_type" {
  description = "代理服务器实例类型"
  type        = string
  default     = "e2-small"
}

# 端口配置
variable "blue_port" {
  description = "蓝环境端口"
  type        = number
  default     = 8081
}

variable "green_port" {
  description = "绿环境端口"
  type        = number
  default     = 8082
}

# 健康检查配置
variable "health_check_path" {
  description = "健康检查路径"
  type        = string
  default     = "/health"
}

# 部署路径
variable "deploy_path" {
  description = "应用部署路径"
  type        = string
  default     = "/var/www"
}
