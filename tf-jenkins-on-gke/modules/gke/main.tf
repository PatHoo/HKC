/**
 * tf-jenkins-on-gke GKE 集群配置
 * 创建日期: 2025-07-08
 */

resource "google_container_cluster" "primary" {
  name               = var.name
  location           = var.zone
  project            = var.project_id
  
  # 我们使用单独的节点池
  remove_default_node_pool = true
  initial_node_count       = 1

  # 使用网络模块提供的网络和子网
  network    = var.network
  subnetwork = var.subnetwork

  # 启用工作负载身份
  workload_identity_config {
    workload_pool = "${var.project_id}.svc.id.goog"
  }

  # 启用私有集群功能
  private_cluster_config {
    enable_private_nodes    = false
    enable_private_endpoint = false
  }

  # 启用网络策略
  network_policy {
    enabled  = true
    provider = "CALICO"
  }

  # 启用 Pod 安全策略
  pod_security_policy_config {
    enabled = false
  }
}

resource "google_container_node_pool" "primary_nodes" {
  name       = "${var.name}-node-pool"
  location   = var.zone
  cluster    = google_container_cluster.primary.name
  project    = var.project_id
  node_count = var.node_count

  node_config {
    machine_type = var.machine_type
    
    # Google 推荐的最小标签集
    metadata = {
      disable-legacy-endpoints = "true"
    }

    # 设置 OAuth 范围
    oauth_scopes = [
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
      "https://www.googleapis.com/auth/devstorage.read_only",
      "https://www.googleapis.com/auth/compute",
    ]

    # 启用工作负载身份
    workload_metadata_config {
      mode = "GKE_METADATA"
    }
  }

  # 自动修复和自动升级
  management {
    auto_repair  = true
    auto_upgrade = true
  }

  # 自动扩缩容配置
  autoscaling {
    min_node_count = 1
    max_node_count = 5
  }
}
