resource "kubernetes_deployment" "jenkins_blue" {
  metadata {
    name      = "jenkins-blue"
    namespace = kubernetes_namespace.jenkins.metadata[0].name
    labels = {
      app = "jenkins"
      env = "blue"
    }
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "jenkins"
        env = "blue"
      }
    }

    template {
      metadata {
        labels = {
          app = "jenkins"
          env = "blue"
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
            name       = "jenkins-home-blue"
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
          name = "jenkins-home-blue"
          persistent_volume_claim {
            claim_name = kubernetes_persistent_volume_claim.jenkins_home_blue.metadata[0].name
          }
        }
      }
    }
  }
}

resource "kubernetes_deployment" "jenkins_green" {
  metadata {
    name      = "jenkins-green"
    namespace = kubernetes_namespace.jenkins.metadata[0].name
    labels = {
      app = "jenkins"
      env = "green"
    }
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "jenkins"
        env = "green"
      }
    }

    template {
      metadata {
        labels = {
          app = "jenkins"
          env = "green"
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
            name       = "jenkins-home-green"
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
          name = "jenkins-home-green"
          persistent_volume_claim {
            claim_name = kubernetes_persistent_volume_claim.jenkins_home_green.metadata[0].name
          }
        }
      }
    }
  }
}

resource "kubernetes_persistent_volume_claim" "jenkins_home_blue" {
  metadata {
    name      = "jenkins-home-blue"
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

resource "kubernetes_persistent_volume_claim" "jenkins_home_green" {
  metadata {
    name      = "jenkins-home-green"
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
