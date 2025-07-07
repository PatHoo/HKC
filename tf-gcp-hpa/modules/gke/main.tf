/**
 * GCP Terraform HPA 实现 - GKE 模块
 * 创建日期: 2025-07-07
 */

# 创建 GKE 集群
resource "google_container_cluster" "primary" {
  name     = var.cluster_name
  location = var.region

  # 我们不使用默认节点池，而是创建自定义节点池
  remove_default_node_pool = true
  initial_node_count       = 1

  network    = var.network
  subnetwork = var.subnetwork

  ip_allocation_policy {
    cluster_secondary_range_name  = var.ip_range_pods
    services_secondary_range_name = var.ip_range_services
  }

  # 启用 Workload Identity
  workload_identity_config {
    workload_pool = "${var.project_id}.svc.id.goog"
  }

  # 启用 HPA 所需的监控
  monitoring_config {
    enable_components = ["SYSTEM_COMPONENTS"]
  }

  # 启用 VPA
  vertical_pod_autoscaling {
    enabled = true
  }

  # 启用集群自动扩缩容
  cluster_autoscaling {
    enabled = true
    resource_limits {
      resource_type = "cpu"
      minimum       = 1
      maximum       = 10
    }
    resource_limits {
      resource_type = "memory"
      minimum       = 2
      maximum       = 20
    }
  }
}

# 创建节点池
resource "google_container_node_pool" "primary_nodes" {
  for_each = { for i, np in var.node_pools : i => np }

  name       = each.value.name
  location   = var.region
  cluster    = google_container_cluster.primary.name
  node_count = lookup(each.value, "min_count", 1)

  autoscaling {
    min_node_count = lookup(each.value, "min_count", 1)
    max_node_count = lookup(each.value, "max_count", 3)
  }

  management {
    auto_repair  = lookup(each.value, "auto_repair", true)
    auto_upgrade = lookup(each.value, "auto_upgrade", true)
  }

  node_config {
    preemptible  = lookup(each.value, "preemptible", false)
    machine_type = lookup(each.value, "machine_type", "e2-medium")
    disk_size_gb = lookup(each.value, "disk_size_gb", 100)
    disk_type    = lookup(each.value, "disk_type", "pd-standard")
    image_type   = lookup(each.value, "image_type", "COS_CONTAINERD")

    # 设置 OAuth 作用域
    oauth_scopes = lookup(var.node_pools_oauth_scopes, "all", [
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
    ])

    # 设置标签
    dynamic "labels" {
      for_each = lookup(var.node_pools_labels, each.value.name, {})
      content {
        key   = labels.key
        value = labels.value
      }
    }

    # 设置元数据
    dynamic "metadata" {
      for_each = lookup(var.node_pools_metadata, each.value.name, {})
      content {
        key   = metadata.key
        value = metadata.value
      }
    }

    # 设置污点
    dynamic "taint" {
      for_each = lookup(var.node_pools_taints, each.value.name, [])
      content {
        key    = taint.value.key
        value  = taint.value.value
        effect = taint.value.effect
      }
    }

    # 设置网络标签
    tags = lookup(var.node_pools_tags, each.value.name, [])

    # 启用 Workload Identity
    workload_metadata_config {
      mode = "GKE_METADATA"
    }
  }
}
