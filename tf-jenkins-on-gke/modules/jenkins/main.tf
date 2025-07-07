resource "kubernetes_namespace" "jenkins" {
  metadata {
    name = var.namespace
  }
}

resource "kubernetes_service_account" "jenkins" {
  metadata {
    name      = "jenkins"
    namespace = kubernetes_namespace.jenkins.metadata[0].name
  }
}

resource "kubernetes_cluster_role_binding" "jenkins" {
  metadata {
    name = "jenkins-admin"
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "cluster-admin"
  }
  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account.jenkins.metadata[0].name
    namespace = kubernetes_namespace.jenkins.metadata[0].name
  }
}

resource "kubernetes_persistent_volume_claim" "jenkins_home" {
  metadata {
    name      = "jenkins-home"
    namespace = kubernetes_namespace.jenkins.metadata[0].name
  }
  spec {
    access_modes = ["ReadWriteOnce"]
    resources {
      requests = {
        storage = "10Gi"
      }
    }
    storage_class_name = "standard"
  }
}

resource "kubernetes_deployment" "jenkins" {
  metadata {
    name      = "jenkins"
    namespace = kubernetes_namespace.jenkins.metadata[0].name
    labels = {
      app = "jenkins"
    }
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "jenkins"
      }
    }

    template {
      metadata {
        labels = {
          app = "jenkins"
        }
      }

      spec {
        service_account_name = kubernetes_service_account.jenkins.metadata[0].name
        
        container {
          name  = "jenkins"
          image = "jenkins/jenkins:lts"
          
          port {
            name           = "http"
            container_port = 8080
          }
          
          port {
            name           = "jnlp"
            container_port = 50000
          }
          
          resources {
            limits = {
              cpu    = "1000m"
              memory = "2Gi"
            }
            requests = {
              cpu    = "500m"
              memory = "1Gi"
            }
          }
          
          volume_mount {
            name       = "jenkins-home"
            mount_path = "/var/jenkins_home"
          }
          
          liveness_probe {
            http_get {
              path = "/login"
              port = "http"
            }
            initial_delay_seconds = 90
            timeout_seconds       = 5
            period_seconds        = 10
            failure_threshold     = 5
          }
          
          readiness_probe {
            http_get {
              path = "/login"
              port = "http"
            }
            initial_delay_seconds = 60
            timeout_seconds       = 5
            period_seconds        = 10
            failure_threshold     = 3
          }
        }
        
        volume {
          name = "jenkins-home"
          persistent_volume_claim {
            claim_name = kubernetes_persistent_volume_claim.jenkins_home.metadata[0].name
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "jenkins" {
  metadata {
    name      = "jenkins"
    namespace = kubernetes_namespace.jenkins.metadata[0].name
    labels = {
      app = "jenkins"
    }
  }
  
  spec {
    selector = {
      app = "jenkins"
    }
    
    port {
      name        = "http"
      port        = 8080
      target_port = "http"
    }
    
    port {
      name        = "jnlp"
      port        = 50000
      target_port = "jnlp"
    }
    
    type = "LoadBalancer"
  }
}

# 为蓝绿部署创建额外的服务
resource "kubernetes_service" "jenkins_blue" {
  metadata {
    name      = "jenkins-blue"
    namespace = kubernetes_namespace.jenkins.metadata[0].name
    labels = {
      app = "jenkins"
      env = "blue"
    }
  }
  
  spec {
    selector = {
      app = "jenkins"
      env = "blue"
    }
    
    port {
      name        = "http"
      port        = 8080
      target_port = "http"
    }
    
    port {
      name        = "jnlp"
      port        = 50000
      target_port = "jnlp"
    }
    
    type = "ClusterIP"
  }
}

resource "kubernetes_service" "jenkins_green" {
  metadata {
    name      = "jenkins-green"
    namespace = kubernetes_namespace.jenkins.metadata[0].name
    labels = {
      app = "jenkins"
      env = "green"
    }
  }
  
  spec {
    selector = {
      app = "jenkins"
      env = "green"
    }
    
    port {
      name        = "http"
      port        = 8080
      target_port = "http"
    }
    
    port {
      name        = "jnlp"
      port        = 50000
      target_port = "jnlp"
    }
    
    type = "ClusterIP"
  }
}
