/**
 * tf-hsbc-interview Jenkins 蓝/绿部署配置
 */

# 创建蓝色部署
resource "kubernetes_deployment" "jenkins_blue" {
  metadata {
    name      = "jenkins-blue"
    namespace = kubernetes_namespace.jenkins.metadata[0].name
    labels = {
      app     = "jenkins"
      version = "blue"
    }
  }
  
  spec {
    replicas = var.enable_jenkins ? (var.blue_deployment_active ? 1 : 0) : 0
    
    selector {
      match_labels = {
        app     = "jenkins"
        version = "blue"
      }
    }
    
    template {
      metadata {
        labels = {
          app     = "jenkins"
          version = "blue"
        }
      }
      
      spec {
        service_account_name = kubernetes_service_account.jenkins.metadata[0].name
        
        container {
          name  = "jenkins"
          image = var.jenkins_blue_image
          
          resources {
            limits = {
              cpu    = var.jenkins_cpu_limit
              memory = var.jenkins_memory_limit
            }
            requests = {
              cpu    = var.jenkins_cpu_request
              memory = var.jenkins_memory_request
            }
          }
          
          port {
            name           = "http"
            container_port = 8080
          }
          
          port {
            name           = "jnlp"
            container_port = 50000
          }
          
          env {
            name  = "JAVA_OPTS"
            value = "-Djenkins.install.runSetupWizard=false -Dhudson.model.DownloadService.noSignatureCheck=true"
          }
          
          env {
            name  = "JENKINS_DEPLOYMENT_VERSION"
            value = "blue"
          }
          
          liveness_probe {
            http_get {
              path = "/login"
              port = "http"
            }
            initial_delay_seconds = 90
            timeout_seconds       = 5
            period_seconds        = 10
            failure_threshold     = 10
          }
          
          readiness_probe {
            http_get {
              path = "/login"
              port = "http"
            }
            initial_delay_seconds = 90
            timeout_seconds       = 5
            period_seconds        = 10
            failure_threshold     = 10
          }
          
          volume_mount {
            name       = "jenkins-home"
            mount_path = "/var/jenkins_home"
          }
          
          security_context {
            run_as_user = 1000

          }
        }
        
        volume {
          name = "jenkins-home"
          persistent_volume_claim {
            claim_name = kubernetes_persistent_volume_claim.jenkins_pvc.metadata[0].name
          }
        }
      }
    }
  }
}

# 创建绿色部署
resource "kubernetes_deployment" "jenkins_green" {
  metadata {
    name      = "jenkins-green"
    namespace = kubernetes_namespace.jenkins.metadata[0].name
    labels = {
      app     = "jenkins"
      version = "green"
    }
  }
  
  spec {
    replicas = var.enable_jenkins ? (var.blue_deployment_active ? 0 : 1) : 0
    
    selector {
      match_labels = {
        app     = "jenkins"
        version = "green"
      }
    }
    
    template {
      metadata {
        labels = {
          app     = "jenkins"
          version = "green"
        }
      }
      
      spec {
        service_account_name = kubernetes_service_account.jenkins.metadata[0].name
        
        container {
          name  = "jenkins"
          image = var.jenkins_green_image
          
          resources {
            limits = {
              cpu    = var.jenkins_cpu_limit
              memory = var.jenkins_memory_limit
            }
            requests = {
              cpu    = var.jenkins_cpu_request
              memory = var.jenkins_memory_request
            }
          }
          
          port {
            name           = "http"
            container_port = 8080
          }
          
          port {
            name           = "jnlp"
            container_port = 50000
          }
          
          env {
            name  = "JAVA_OPTS"
            value = "-Djenkins.install.runSetupWizard=false -Dhudson.model.DownloadService.noSignatureCheck=true"
          }
          
          env {
            name  = "JENKINS_DEPLOYMENT_VERSION"
            value = "green"
          }
          
          liveness_probe {
            http_get {
              path = "/login"
              port = "http"
            }
            initial_delay_seconds = 90
            timeout_seconds       = 5
            period_seconds        = 10
            failure_threshold     = 10
          }
          
          readiness_probe {
            http_get {
              path = "/login"
              port = "http"
            }
            initial_delay_seconds = 90
            timeout_seconds       = 5
            period_seconds        = 10
            failure_threshold     = 10
          }
          
          volume_mount {
            name       = "jenkins-home"
            mount_path = "/var/jenkins_home"
          }
          
          security_context {
            run_as_user = 1000

          }
        }
        
        volume {
          name = "jenkins-home"
          persistent_volume_claim {
            claim_name = kubernetes_persistent_volume_claim.jenkins_pvc.metadata[0].name
          }
        }
      }
    }
  }
}

# 创建蓝/绿服务（路由到当前活跃的部署）
resource "kubernetes_service" "jenkins_blue_green" {
  metadata {
    name      = "jenkins-blue-green"
    namespace = kubernetes_namespace.jenkins.metadata[0].name
    labels = {
      app = "jenkins"
    }
  }
  
  spec {
    selector = {
      app     = "jenkins"
      version = var.blue_deployment_active ? "blue" : "green"
    }
    
    port {
      name        = "http"
      port        = 80
      target_port = 8080
    }
    
    port {
      name        = "jnlp"
      port        = 50000
      target_port = 50000
    }
    
    type = var.jenkins_service_type
  }
}
