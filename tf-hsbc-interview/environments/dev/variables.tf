/**
 * tf-hsbc-interview 开发环境变量
 */

# 基本设置
variable "project_id" {
  description = "GCP 项目 ID"
  type        = string
}

variable "region" {
  description = "GCP 区域"
  type        = string
  default     = "asia-east1"
}

variable "environment" {
  description = "环境名称"
  type        = string
  default     = "dev"
}

# 网络设置
variable "subnet_ip_cidr_range" {
  description = "子网 IP CIDR 范围"
  type        = string
  default     = "10.0.0.0/24"
}

variable "ip_range_pods_cidr" {
  description = "GKE Pods IP CIDR 范围"
  type        = string
  default     = "10.1.0.0/16"
}

variable "ip_range_services_cidr" {
  description = "GKE Services IP CIDR 范围"
  type        = string
  default     = "10.2.0.0/16"
}

# GKE 集群设置
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
  default     = 3
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
  default     = true
}

# Jenkins 设置
variable "jenkins_image" {
  description = "Jenkins 镜像"
  type        = string
  default     = "jenkins/jenkins:lts"
}

variable "jenkins_storage_size" {
  description = "Jenkins 存储大小"
  type        = string
  default     = "10Gi"
}

variable "storage_class_name" {
  description = "存储类名称"
  type        = string
  default     = "standard"
}

variable "jenkins_cpu_limit" {
  description = "Jenkins CPU 限制"
  type        = string
  default     = "1000m"
}

variable "jenkins_memory_limit" {
  description = "Jenkins 内存限制"
  type        = string
  default     = "2Gi"
}

variable "jenkins_cpu_request" {
  description = "Jenkins CPU 请求"
  type        = string
  default     = "500m"
}

variable "jenkins_memory_request" {
  description = "Jenkins 内存请求"
  type        = string
  default     = "1Gi"
}

variable "jenkins_service_type" {
  description = "Jenkins 服务类型"
  type        = string
  default     = "LoadBalancer"
}

# Jenkins 蓝/绿部署设置
variable "jenkins_blue_image" {
  description = "Jenkins 蓝色部署镜像"
  type        = string
  default     = "jenkins/jenkins:lts"
}

variable "jenkins_green_image" {
  description = "Jenkins 绿色部署镜像"
  type        = string
  default     = "jenkins/jenkins:lts-jdk17"
}

variable "blue_deployment_active" {
  description = "是否激活蓝色部署"
  type        = bool
  default     = true
}

# HPA 演示设置
variable "hpa_app_image" {
  description = "HPA 演示应用镜像"
  type        = string
  default     = "k8s.gcr.io/hpa-example"
}

variable "hpa_initial_replicas" {
  description = "HPA 初始副本数"
  type        = number
  default     = 2
}

variable "hpa_min_replicas" {
  description = "HPA 最小副本数"
  type        = number
  default     = 1
}

variable "hpa_max_replicas" {
  description = "HPA 最大副本数"
  type        = number
  default     = 10
}

variable "hpa_target_cpu_utilization" {
  description = "HPA 目标 CPU 利用率百分比"
  type        = number
  default     = 50
}

variable "hpa_service_type" {
  description = "HPA 服务类型"
  type        = string
  default     = "LoadBalancer"
}
