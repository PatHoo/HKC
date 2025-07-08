#!/bin/bash

# 参数处理
while [[ $# -gt 0 ]]; do
  case "$1" in
    -e|--environment)
      ENVIRONMENT="$2"
      shift 2
      ;;
    -p|--project-id)
      PROJECT_ID="$2"
      shift 2
      ;;
    -r|--region)
      REGION="$2"
      shift 2
      ;;
    -s|--service-account)
      SERVICE_ACCOUNT_ID="$2"
      shift 2
      ;;
    *)
      echo "Unknown parameter: $1"
      exit 1
      ;;
  esac
done

# 验证必要参数
if [[ -z "$ENVIRONMENT" || -z "$PROJECT_ID" ]]; then
  echo "Usage: $0 -e|--environment <environment> -p|--project-id <project_id> [options]"
  echo "Options:"
  echo "  -r, --region <region>             GCP region (default: asia-east1)"
  echo "  -s, --service-account <account>    Service account ID (default: terraform)"
  exit 1
fi

# 设置默认值
: "${REGION:=asia-east1}"
: "${SERVICE_ACCOUNT_ID:=terraform}"

# 验证环境
valid_environments=("dev" "stage" "prod")
if [[ ! " ${valid_environments[@]} " =~ " ${ENVIRONMENT} " ]]; then
  echo "错误: 无效的环境 '${ENVIRONMENT}'. 必须是: ${valid_environments[*]}"
  exit 1
fi

# 创建环境目录（如果不存在）
env_dir="../environments/${ENVIRONMENT}"
mkdir -p "${env_dir}"

# 从模板生成 backend.tf
backend_template="../environments/_templates/backend.tf.tpl"
if [[ ! -f "${backend_template}" ]]; then
  echo "错误: 模板文件 ${backend_template} 不存在"
  exit 1
fi

# 创建 backend.tf
sed -e "s/\$\{project_id\}/${PROJECT_ID}/g" \
   -e "s/\$\{environment\}/${ENVIRONMENT}/g" \
   "${backend_template}" > "${env_dir}/backend.tf"

# 创建 terraform.tfvars 文件（如果不存在）
tf_vars_path="${env_dir}/terraform.tfvars"
if [[ ! -f "${tf_vars_path}" ]]; then
  cat > "${tf_vars_path}" <<EOF
project_id = "${PROJECT_ID}"
region = "${REGION}"
environment = "${ENVIRONMENT}"

# 根据需要添加其他变量
# 示例:
# cluster_name = "gke-${ENVIRONMENT}"
# node_count = 2
EOF
fi

# 创建 versions.tf 文件（如果不存在）
versions_path="${env_dir}/versions.tf"
if [[ ! -f "${versions_path}" ]]; then
  cat > "${versions_path}" <<'EOF'
terraform {
  required_version = ">= 1.0.0"
  
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 4.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.10"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.8"
    }
  }
}
EOF
fi

# 创建 main.tf 文件（如果不存在）
main_tf_path="${env_dir}/main.tf"
if [[ ! -f "${main_tf_path}" ]]; then
  cat > "${main_tf_path}" <<'EOF'
# Provider 配置
provider "google" {
  project = var.project_id
  region  = var.region
}

# 模块调用将在这里添加
# 例如:
# module "gke" {
#   source = "../../modules/gke"
#   ...
# }
EOF
fi

# 初始化 Terraform
echo "正在为 ${ENVIRONMENT} 环境初始化 Terraform..."
(cd "${env_dir}" && terraform init -input=false)

# 输出成功信息
echo -e "\n环境 '${ENVIRONMENT}' 已成功初始化！"
echo "下一步："
echo "1. 检查并更新配置: $(realpath "${tf_vars_path}")"
echo "2. 运行 'terraform plan' 查看执行计划"
echo "3. 运行 'terraform apply' 应用配置"
