#!/bin/bash
# 蓝/绿部署切换脚本

# 检查参数
if [ "$#" -lt 2 ]; then
    echo "用法: $0 <环境> <部署颜色> [项目ID]"
    echo "环境: dev 或 prod"
    echo "部署颜色: blue 或 green"
    echo "项目ID: 可选，GCP 项目 ID"
    exit 1
fi

# 设置变量
ENV=$1
COLOR=$2
PROJECT_ID=$3

# 验证参数
if [ "$ENV" != "dev" ] && [ "$ENV" != "prod" ]; then
    echo "错误: 环境必须是 'dev' 或 'prod'"
    exit 1
fi

if [ "$COLOR" != "blue" ] && [ "$COLOR" != "green" ]; then
    echo "错误: 部署颜色必须是 'blue' 或 'green'"
    exit 1
fi

# 设置工作目录
WORKDIR="$(dirname "$0")/../environments/$ENV"
cd "$WORKDIR" || exit 1

# 设置部署颜色变量
if [ "$COLOR" == "blue" ]; then
    ACTIVE="true"
else
    ACTIVE="false"
fi

# 执行 Terraform 命令
echo "切换到 $COLOR 部署..."

if [ -n "$PROJECT_ID" ]; then
    terraform apply -auto-approve -var="project_id=$PROJECT_ID" -var="blue_deployment_active=$ACTIVE"
else
    terraform apply -auto-approve -var="blue_deployment_active=$ACTIVE"
fi

# 检查结果
if [ $? -eq 0 ]; then
    echo "成功切换到 $COLOR 部署！"
    
    # 获取 Jenkins URL
    JENKINS_URL=$(terraform output -raw jenkins_url)
    echo "Jenkins 可通过以下 URL 访问: $JENKINS_URL"
else
    echo "切换失败，请检查错误信息。"
    exit 1
fi
