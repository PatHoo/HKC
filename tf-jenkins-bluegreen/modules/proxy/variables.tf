/**
 * 代理模块变量定义
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

variable "machine_type" {
  description = "代理服务器实例类型"
  type        = string
}

variable "active_env" {
  description = "当前活动环境（blue 或 green）"
  type        = string
  validation {
    condition     = var.active_env == "blue" || var.active_env == "green"
    error_message = "活动环境必须是 'blue' 或 'green'。"
  }
}

variable "blue_address" {
  description = "蓝环境实例 IP 地址"
  type        = string
}

variable "green_address" {
  description = "绿环境实例 IP 地址"
  type        = string
}

variable "blue_port" {
  description = "蓝环境端口"
  type        = number
}

variable "green_port" {
  description = "绿环境端口"
  type        = number
}
