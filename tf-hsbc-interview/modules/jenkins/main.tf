/**
 * tf-hsbc-interview Jenkins 模块
 * 部署 Jenkins 到 GKE 集群
 */

# 创建 Jenkins 命名空间
resource "kubernetes_namespace" "jenkins" {
  metadata {
    name = var.jenkins_namespace
  }
}

# 创建 Jenkins 持久卷声明
resource "kubernetes_persistent_volume_claim" "jenkins_pvc" {
  metadata {
    name      = "jenkins-pvc"
    namespace = kubernetes_namespace.jenkins.metadata[0].name
  }
  
  spec {
    access_modes = ["ReadWriteOnce"]
    resources {
      requests = {
        storage = var.jenkins_storage_size
      }
    }
    storage_class_name = var.storage_class_name
  }
}

# 创建 Jenkins 部署
resource "kubernetes_deployment" "jenkins" {
  metadata {
    name      = "jenkins"
    namespace = kubernetes_namespace.jenkins.metadata[0].name
    labels = {
      app = "jenkins"
    }
  }
  
  spec {
    replicas = var.enable_jenkins ? 1 : 0
    
    selector {
      match_labels = {
        app = "jenkins"
      }
    }
    
    strategy {
      type = "Recreate"
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
          image = var.jenkins_image
          
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
          
          liveness_probe {
            http_get {
              path = "/login"
              port = "http"
            }
            initial_delay_seconds = 180
            timeout_seconds       = 5
            period_seconds        = 10
            failure_threshold     = 10
          }
          
          readiness_probe {
            http_get {
              path = "/login"
              port = "http"
            }
            initial_delay_seconds = 180
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

# 创建 Jenkins 服务
resource "kubernetes_service" "jenkins" {
  metadata {
    name      = "jenkins"
    namespace = kubernetes_namespace.jenkins.metadata[0].name
  }
  
  spec {
    selector = {
      app = "jenkins"
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

# 创建 Jenkins ServiceAccount
resource "kubernetes_service_account" "jenkins" {
  metadata {
    name      = "jenkins"
    namespace = kubernetes_namespace.jenkins.metadata[0].name
  }
}

# 创建 Jenkins ClusterRole
resource "kubernetes_cluster_role" "jenkins" {
  metadata {
    name = "jenkins-role"
  }
  
  rule {
    api_groups = [""]
    resources  = ["pods", "services", "configmaps", "secrets", "events", "namespaces"]
    verbs      = ["create", "get", "watch", "list", "update", "patch", "delete"]
  }
  
  rule {
    api_groups = ["apps"]
    resources  = ["deployments", "replicasets"]
    verbs      = ["create", "get", "watch", "list", "update", "patch", "delete"]
  }
  
  rule {
    api_groups = ["extensions"]
    resources  = ["deployments", "ingresses"]
    verbs      = ["create", "get", "watch", "list", "update", "patch", "delete"]
  }
  
  rule {
    api_groups = ["networking.k8s.io"]
    resources  = ["ingresses"]
    verbs      = ["create", "get", "watch", "list", "update", "patch", "delete"]
  }
}

# 创建 Jenkins ClusterRoleBinding
resource "kubernetes_cluster_role_binding" "jenkins" {
  metadata {
    name = "jenkins-role-binding"
  }
  
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = kubernetes_cluster_role.jenkins.metadata[0].name
  }
  
  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account.jenkins.metadata[0].name
    namespace = kubernetes_namespace.jenkins.metadata[0].name
  }
}
