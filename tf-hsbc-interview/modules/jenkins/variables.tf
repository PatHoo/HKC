/**
 * tf-hsbc-interview Jenkins 模块变量
 */

variable "jenkins_namespace" {
  description = "Jenkins 命名空间"
  type        = string
  default     = "jenkins"
}

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

# 蓝/绿部署相关变量
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

variable "enable_jenkins" {
  description = "是否启用 Jenkins 部署"
  type        = bool
  default     = true
}
