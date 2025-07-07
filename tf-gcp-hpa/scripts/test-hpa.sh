#!/bin/bash
# GCP Terraform HPA 测试脚本
# 创建日期: 2025-07-07

# 确保脚本在出错时退出
set -e

# 颜色定义
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${GREEN}===== GCP Terraform HPA 测试脚本 =====${NC}"

# 检查是否已连接到集群
echo -e "${YELLOW}检查集群连接...${NC}"
if ! kubectl cluster-info &> /dev/null; then
  echo -e "${RED}错误: 未连接到 Kubernetes 集群${NC}"
  echo "请运行以下命令连接到集群:"
  echo "gcloud container clusters get-credentials \$(terraform output -raw cluster_name) --region \$(terraform output -raw cluster_location)"
  exit 1
fi

# 获取命名空间
NAMESPACE=$(terraform output -raw app_namespace)
APP_NAME=$(terraform output -raw app_deployment_name)
HPA_NAME=$(terraform output -raw hpa_name)

echo -e "${GREEN}已连接到集群，使用命名空间: ${NAMESPACE}${NC}"

# 显示初始状态
echo -e "${YELLOW}初始部署状态:${NC}"
kubectl get deployment -n $NAMESPACE $APP_NAME -o wide
echo

echo -e "${YELLOW}初始 HPA 状态:${NC}"
kubectl get hpa -n $NAMESPACE $HPA_NAME
echo

# 提示用户
echo -e "${GREEN}准备测试 HPA...${NC}"
echo "此测试将创建一个负载生成器 Pod，向应用发送持续请求以增加 CPU 负载。"
echo "在另一个终端窗口运行以下命令来监控 HPA 状态:"
echo -e "${YELLOW}kubectl get hpa -n $NAMESPACE $HPA_NAME -w${NC}"
echo

read -p "按 Enter 键开始测试，或 Ctrl+C 取消..."

# 启动负载生成器
echo -e "${GREEN}启动负载生成器...${NC}"
echo "运行以下命令:"
echo -e "${YELLOW}kubectl run -i --tty load-generator --rm --image=busybox --restart=Never -- /bin/sh -c \"while sleep 0.01; do wget -q -O- http://$APP_NAME.$NAMESPACE.svc.cluster.local; done\"${NC}"

kubectl run -i --tty load-generator --rm --image=busybox --restart=Never -- /bin/sh -c "while sleep 0.01; do wget -q -O- http://$APP_NAME.$NAMESPACE.svc.cluster.local; done"

# 注意：上面的命令会阻塞，直到用户按 Ctrl+C 退出
# 脚本的其余部分不会执行，除非负载生成器被终止
