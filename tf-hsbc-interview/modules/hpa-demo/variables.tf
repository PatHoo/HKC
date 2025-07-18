/**
 * tf-hsbc-interview HPA 演示模块变量
 */

variable "namespace" {
  description = "HPA 演示应用命名空间"
  type        = string
  default     = "hpa-demo"
}

variable "app_image" {
  description = "演示应用镜像"
  type        = string
  default     = "gcr.io/google_containers/hpa-example"
  # 注意: 如果上述镜像也无法访问，可以尝试以下镜像：
  # default     = "nginx:latest"  # 使用普通的 nginx 镜像作为替代
  # default     = "paulbouwer/hello-kubernetes:1.10"  # 使用可靠的测试镜像
}

variable "initial_replicas" {
  description = "初始副本数"
  type        = number
  default     = 2
}

variable "min_replicas" {
  description = "最小副本数"
  type        = number
  default     = 1
}

variable "max_replicas" {
  description = "最大副本数"
  type        = number
  default     = 10
}

variable "target_cpu_utilization_percentage" {
  description = "目标 CPU 利用率百分比"
  type        = number
  default     = 50
}

variable "target_memory_utilization_percentage" {
  description = "目标内存利用率百分比"
  type        = number
  default     = 50
}

variable "cpu_request" {
  description = "CPU 请求"
  type        = string
  default     = "200m"
}

variable "cpu_limit" {
  description = "CPU 限制"
  type        = string
  default     = "500m"
}

variable "memory_request" {
  description = "内存请求"
  type        = string
  default     = "256Mi"
}

variable "memory_limit" {
  description = "内存限制"
  type        = string
  default     = "512Mi"
}

variable "service_type" {
  description = "服务类型"
  type        = string
  default     = "LoadBalancer"
}
