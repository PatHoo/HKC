/**
 * tf-hsbc-interview Jenkins 蓝/绿部署独立 PVC 配置
 */

# 创建 Jenkins 蓝色部署持久卷声明
resource "kubernetes_persistent_volume_claim" "jenkins_blue_pvc" {
  metadata {
    name      = "jenkins-blue-pvc"
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

# 创建 Jenkins 绿色部署持久卷声明
resource "kubernetes_persistent_volume_claim" "jenkins_green_pvc" {
  metadata {
    name      = "jenkins-green-pvc"
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
