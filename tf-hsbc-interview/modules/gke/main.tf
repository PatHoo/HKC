/**
 * tf-hsbc-interview GKE 模块
 * 创建 Google Kubernetes Engine 集群
 */

resource "google_container_cluster" "primary" {
  name     = var.cluster_name
  project  = var.project_id
  location = var.region
  
  # 我们使用单独的节点池
  remove_default_node_pool = true
  initial_node_count       = 1
  
  network    = var.network_self_link
  subnetwork = var.subnet_self_link
  
  # 配置私有集群
  private_cluster_config {
    enable_private_nodes    = var.enable_private_nodes
    enable_private_endpoint = var.enable_private_endpoint
    master_ipv4_cidr_block  = var.master_ipv4_cidr_block
  }
  
  # 配置 IP 别名
  ip_allocation_policy {
    cluster_secondary_range_name  = var.ip_range_pods_name
    services_secondary_range_name = var.ip_range_services_name
  }
  
  # 启用工作负载身份
  workload_identity_config {
    workload_pool = "${var.project_id}.svc.id.goog"
  }
  
  # 启用网络策略
  network_policy {
    enabled  = true
    provider = "CALICO"
  }
  
  # 配置集群自动缩放
  cluster_autoscaling {
    enabled = true
    
    resource_limits {
      resource_type = "cpu"
      minimum       = 1
      maximum       = 32
    }
    
    resource_limits {
      resource_type = "memory"
      minimum       = 2
      maximum       = 64
    }
  }
  
  # 配置维护窗口
  maintenance_policy {
    daily_maintenance_window {
      start_time = "03:00"
    }
  }
  
  # 配置日志和监控
  logging_service    = "logging.googleapis.com/kubernetes"
  monitoring_service = "monitoring.googleapis.com/kubernetes"
}

# 创建默认节点池
resource "google_container_node_pool" "primary_nodes" {
  name       = "${var.cluster_name}-node-pool"
  project    = var.project_id
  location   = var.region
  cluster    = google_container_cluster.primary.name
  node_count = var.node_count
  
  node_config {
    preemptible  = var.preemptible
    machine_type = var.machine_type
    disk_size_gb = var.disk_size_gb
    disk_type    = var.disk_type
    
    # Google 推荐的节点元数据设置
    metadata = {
      disable-legacy-endpoints = "true"
    }
    
    # 最小权限原则
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
  
  # 配置节点池自动缩放
  autoscaling {
    min_node_count = var.min_node_count
    max_node_count = var.max_node_count
  }
  
  # 配置节点池自动升级
  management {
    auto_repair  = true
    auto_upgrade = true
  }
}
