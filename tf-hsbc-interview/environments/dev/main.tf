/**
 * tf-hsbc-interview 开发环境配置
 */

provider "google" {
  project = var.project_id
  region  = var.region
}

provider "kubernetes" {
  host                   = "https://${module.gke.cluster_endpoint}"
  token                  = data.google_client_config.default.access_token
  cluster_ca_certificate = module.gke.cluster_ca_certificate
}

data "google_client_config" "default" {}

# 创建网络
module "network" {
  source = "../../modules/network"
  
  project_id              = var.project_id
  region                  = var.region
  network_name            = "${var.environment}-hsbc-vpc"
  subnet_name             = "${var.environment}-hsbc-subnet"
  subnet_ip_cidr_range    = var.subnet_ip_cidr_range
  ip_range_pods_name      = "${var.environment}-ip-range-pods"
  ip_range_pods_cidr      = var.ip_range_pods_cidr
  ip_range_services_name  = "${var.environment}-ip-range-services"
  ip_range_services_cidr  = var.ip_range_services_cidr
}

# 创建 GKE 集群
module "gke" {
  source = "../../modules/gke"
  
  project_id              = var.project_id
  region                  = var.region
  cluster_name            = "${var.environment}-hsbc-cluster"
  network_self_link       = module.network.network_self_link
  subnet_self_link        = module.network.subnet_self_link
  ip_range_pods_name      = module.network.ip_range_pods_name
  ip_range_services_name  = module.network.ip_range_services_name
  
  enable_private_nodes    = var.enable_private_nodes
  enable_private_endpoint = var.enable_private_endpoint
  master_ipv4_cidr_block  = var.master_ipv4_cidr_block
  
  node_count              = var.node_count
  min_node_count          = var.min_node_count
  max_node_count          = var.max_node_count
  machine_type            = var.machine_type
  disk_size_gb            = var.disk_size_gb
  disk_type               = var.disk_type
  preemptible             = var.preemptible
}

# 部署 Jenkins
module "jenkins" {
  source = "../../modules/jenkins"
  
  jenkins_namespace      = "${var.environment}-jenkins"
  jenkins_image          = var.jenkins_image
  jenkins_storage_size   = var.jenkins_storage_size
  storage_class_name     = var.storage_class_name
  jenkins_cpu_limit      = var.jenkins_cpu_limit
  jenkins_memory_limit   = var.jenkins_memory_limit
  jenkins_cpu_request    = var.jenkins_cpu_request
  jenkins_memory_request = var.jenkins_memory_request
  jenkins_service_type   = var.jenkins_service_type
  
  # 蓝/绿部署配置
  jenkins_blue_image     = var.jenkins_blue_image
  jenkins_green_image    = var.jenkins_green_image
  blue_deployment_active = var.blue_deployment_active
  
  depends_on = [module.gke]
}

# 部署 HPA 演示应用
module "hpa_demo" {
  source = "../../modules/hpa-demo"
  
  namespace                         = "${var.environment}-hpa-demo"
  app_image                         = var.hpa_app_image
  initial_replicas                  = var.hpa_initial_replicas
  min_replicas                      = var.hpa_min_replicas
  max_replicas                      = var.hpa_max_replicas
  target_cpu_utilization_percentage = var.hpa_target_cpu_utilization
  service_type                      = var.hpa_service_type
  
  depends_on = [module.gke]
}
