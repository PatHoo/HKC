#!/bin/bash

# 默认值
ACTION="apply"
AUTO_APPROVE=""
VAR_FILE=""
VAR_ARGS=()

# 参数处理
while [[ $# -gt 0 ]]; do
  case "$1" in
    -e|--environment)
      ENVIRONMENT="$2"
      shift 2
      ;;
    -a|--action)
      ACTION="$2"
      shift 2
      ;;
    --auto-approve)
      AUTO_APPROVE="-auto-approve"
      shift
      ;;
    --var-file)
      VAR_FILE="$2"
      shift 2
      ;;
    --var)
      VAR_ARGS+=("-var" "$2")
      shift 2
      ;;
    *)
      echo "未知参数: $1"
      exit 1
      ;;
  esac
done

# 验证必要参数
if [[ -z "$ENVIRONMENT" ]]; then
  echo "用法: $0 -e|--environment <环境> [选项]"
  echo ""
  echo "选项:"
  echo "  -a, --action <动作>       要执行的动作 (plan, apply, destroy, 默认为 apply)"
  echo "      --auto-approve        自动批准，不显示确认提示"
  echo "      --var-file <文件>     指定变量文件 (默认为 terraform.tfvars)"
  echo "      --var '名称=值'       设置变量值"
  exit 1
fi

# 设置错误处理
set -euo pipefail

# 设置环境目录
ENV_DIR="../environments/${ENVIRONMENT}"

# 验证环境目录
if [[ ! -d "${ENV_DIR}" ]]; then
  echo "错误: 环境目录不存在: ${ENV_DIR}"
  exit 1
fi

# 切换到环境目录
pushd "${ENV_DIR}" > /dev/null

# 初始化 Terraform（如果尚未初始化）
if [[ ! -d ".terraform" ]]; then
  echo "正在初始化 Terraform..."
  terraform init -input=false
  if [[ $? -ne 0 ]]; then
    echo "错误: Terraform 初始化失败"
    exit 1
  fi
fi

# 格式化代码
echo "正在格式化 Terraform 代码..."
terraform fmt -recursive

# 验证配置
echo "正在验证 Terraform 配置..."
terraform validate
if [[ $? -ne 0 ]]; then
  echo "错误: Terraform 配置验证失败"
  exit 1
fi

# 构建变量参数
VAR_FILE_ARG=""
if [[ -n "${VAR_FILE}" ]]; then
  if [[ -f "${VAR_FILE}" ]]; then
    VAR_FILE_ARG="-var-file=${VAR_FILE}"
  else
    echo "警告: 变量文件不存在: ${VAR_FILE}"
  fi
fi

# 执行 Terraform 命令
case "${ACTION}" in
  plan)
    echo "正在创建执行计划..."
    terraform plan -out=tfplan -input=false ${VAR_FILE_ARG} "${VAR_ARGS[@]}"
    ;;
  apply)
    # 总是先运行 plan
    echo "正在创建并应用执行计划..."
    PLAN_FILE="tfplan.${ENVIRONMENT}.$(date +%Y%m%d%H%M%S)"
    
    terraform plan -out="${PLAN_FILE}" -input=false ${VAR_FILE_ARG} "${VAR_ARGS[@]}"
    if [[ $? -ne 0 ]]; then
      echo "错误: Terraform plan 失败"
      exit 1
    fi
    
    # 应用计划
    echo "正在应用配置..."
    terraform apply ${AUTO_APPROVE} -input=false "${PLAN_FILE}"
    if [[ $? -ne 0 ]]; then
      echo "错误: Terraform apply 失败"
      exit 1
    fi
    
    # 清理计划文件
    if [[ -f "${PLAN_FILE}" ]]; then
      rm -f "${PLAN_FILE}"
    fi
    ;;
  destroy)
    echo "正在销毁基础设施..."
    terraform destroy ${AUTO_APPROVE} -input=false ${VAR_FILE_ARG} "${VAR_ARGS[@]}"
    if [[ $? -ne 0 ]]; then
      echo "错误: Terraform destroy 失败"
      exit 1
    fi
    ;;
  *)
    echo "错误: 未知动作: ${ACTION}"
    exit 1
    ;;
esac

# 返回到原始目录
popd > /dev/null

echo -e "\n操作成功完成！"

# 使用示例:
# 1. 创建执行计划
# ./deploy.sh -e dev -a plan

# 2. 应用配置（需要确认）
# ./deploy.sh -e dev -a apply

# 3. 自动应用配置（无需确认）
# ./deploy.sh -e dev -a apply --auto-approve

# 4. 销毁基础设施
# ./deploy.sh -e dev -a destroy --auto-approve

# 5. 使用自定义变量文件
# ./deploy.sh -e dev -a apply --var-file=custom.tfvars

# 6. 设置变量
# ./deploy.sh -e dev -a apply --var 'instance_type=n1-standard-2' --var 'node_count=3'
