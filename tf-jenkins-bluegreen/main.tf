/**
 * GCP Terraform 蓝绿部署实现
 * 创建日期: 2025-07-08
 */

# 配置 Terraform Google 提供商
terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 4.0"
    }
  }
}

# 定义 Google 提供商配置
provider "google" {
  project = var.project_id
  region  = var.region
  zone    = var.zone
}

# 当前活动环境状态（蓝或绿）
locals {
  active_env = var.active_env
  inactive_env = var.active_env == "blue" ? "green" : "blue"
}

# 创建蓝环境
module "blue" {
  source       = "./modules/blue"
  project_id   = var.project_id
  region       = var.region
  zone         = var.zone
  network      = var.network
  subnetwork   = var.subnetwork
  app_name     = var.app_name
  app_version  = local.active_env == "blue" ? var.app_version : var.previous_version
  environment  = "blue"
  machine_type = var.machine_type
  port         = var.blue_port
  is_active    = local.active_env == "blue"
}

# 创建绿环境
module "green" {
  source       = "./modules/green"
  project_id   = var.project_id
  region       = var.region
  zone         = var.zone
  network      = var.network
  subnetwork   = var.subnetwork
  app_name     = var.app_name
  app_version  = local.active_env == "green" ? var.app_version : var.previous_version
  environment  = "green"
  machine_type = var.machine_type
  port         = var.green_port
  is_active    = local.active_env == "green"
}

# 创建代理服务器（Nginx）
module "proxy" {
  source       = "./modules/proxy"
  project_id   = var.project_id
  region       = var.region
  zone         = var.zone
  network      = var.network
  subnetwork   = var.subnetwork
  app_name     = var.app_name
  machine_type = var.proxy_machine_type
  active_env   = local.active_env
  blue_address = module.blue.instance_address
  green_address = module.green.instance_address
  blue_port    = var.blue_port
  green_port   = var.green_port
  depends_on   = [module.blue, module.green]
}

# 保存当前活动环境状态
resource "local_file" "active_env" {
  content  = local.active_env
  filename = "${path.module}/active_env.txt"
}

# 环境切换操作
resource "null_resource" "switch_environment" {
  triggers = {
    active_env = local.active_env
  }

  provisioner "local-exec" {
    command = "${path.module}/scripts/switch.sh ${local.active_env} ${local.inactive_env}"
  }

  depends_on = [module.proxy]
}
