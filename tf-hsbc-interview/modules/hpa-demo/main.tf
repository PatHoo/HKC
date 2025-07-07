/**
 * tf-hsbc-interview HPA 演示模块
 * 部署示例应用并配置 HPA 以展示 Kubernetes 水平 Pod 自动扩缩容
 */

# 创建 HPA 演示命名空间
resource "kubernetes_namespace" "hpa_demo" {
  metadata {
    name = var.namespace
  }
}

# 部署示例应用
resource "kubernetes_deployment" "hpa_demo" {
  metadata {
    name      = "hpa-demo-app"
    namespace = kubernetes_namespace.hpa_demo.metadata[0].name
    labels = {
      app = "hpa-demo"
    }
  }
  
  spec {
    replicas = var.initial_replicas
    
    selector {
      match_labels = {
        app = "hpa-demo"
      }
    }
    
    template {
      metadata {
        labels = {
          app = "hpa-demo"
        }
      }
      
      spec {
        container {
          name  = "hpa-demo"
          image = var.app_image
          
          resources {
            limits = {
              cpu    = var.cpu_limit
              memory = var.memory_limit
            }
            requests = {
              cpu    = var.cpu_request
              memory = var.memory_request
            }
          }
          
          port {
            container_port = 80
          }
          
          liveness_probe {
            http_get {
              path = "/"
              port = 80
            }
            initial_delay_seconds = 30
            period_seconds        = 10
          }
          
          readiness_probe {
            http_get {
              path = "/"
              port = 80
            }
            initial_delay_seconds = 30
            period_seconds        = 10
          }
        }
      }
    }
  }
}

# 创建服务
resource "kubernetes_service" "hpa_demo" {
  metadata {
    name      = "hpa-demo-service"
    namespace = kubernetes_namespace.hpa_demo.metadata[0].name
  }
  
  spec {
    selector = {
      app = "hpa-demo"
    }
    
    port {
      port        = 80
      target_port = 80
    }
    
    type = var.service_type
  }
}

# 配置 HPA
resource "kubernetes_horizontal_pod_autoscaler_v2" "hpa_demo" {
  metadata {
    name      = "hpa-demo-autoscaler"
    namespace = kubernetes_namespace.hpa_demo.metadata[0].name
  }
  
  spec {
    scale_target_ref {
      api_version = "apps/v1"
      kind        = "Deployment"
      name        = kubernetes_deployment.hpa_demo.metadata[0].name
    }
    
    min_replicas = var.min_replicas
    max_replicas = var.max_replicas
    
    metric {
      type = "Resource"
      resource {
        name = "cpu"
        target {
          type                = "Utilization"
          average_utilization = var.target_cpu_utilization_percentage
        }
      }
    }
    
    metric {
      type = "Resource"
      resource {
        name = "memory"
        target {
          type                = "Utilization"
          average_utilization = var.target_memory_utilization_percentage
        }
      }
    }
    
    behavior {
      scale_up {
        stabilization_window_seconds = 60
        select_policy                = "Max"
        policy {
          type           = "Pods"
          value          = 1
          period_seconds = 60
        }
        policy {
          type           = "Percent"
          value          = 100
          period_seconds = 60
        }
      }
      
      scale_down {
        stabilization_window_seconds = 300
        select_policy                = "Min"
        policy {
          type           = "Pods"
          value          = 1
          period_seconds = 60
        }
        policy {
          type           = "Percent"
          value          = 10
          period_seconds = 60
        }
      }
    }
  }
}
