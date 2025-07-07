#!/bin/bash

# Jenkins 蓝绿发布测试脚本
# 用法: ./test-blue-green.sh <namespace>

set -e

NAMESPACE=$1

if [ -z "$NAMESPACE" ]; then
  echo "用法: ./test-blue-green.sh <namespace>"
  echo "例如: ./test-blue-green.sh jenkins"
  exit 1
fi

echo "开始测试 Jenkins 蓝绿发布功能..."

# 检查 Jenkins 服务是否存在
echo "检查 Jenkins 服务..."
kubectl get service jenkins -n $NAMESPACE || { echo "错误: Jenkins 服务不存在"; exit 1; }

# 检查蓝色和绿色部署是否存在
echo "检查蓝色和绿色部署..."
kubectl get deployment jenkins-blue -n $NAMESPACE || { echo "错误: Jenkins 蓝色部署不存在"; exit 1; }
kubectl get deployment jenkins-green -n $NAMESPACE || { echo "错误: Jenkins 绿色部署不存在"; exit 1; }

# 获取当前服务指向的环境
CURRENT_ENV=$(kubectl get service jenkins -n $NAMESPACE -o jsonpath='{.spec.selector.env}')
echo "当前 Jenkins 服务指向: $CURRENT_ENV 环境"

# 确定目标环境（与当前环境相反）
if [ "$CURRENT_ENV" == "blue" ]; then
  TARGET_ENV="green"
else
  TARGET_ENV="blue"
fi

echo "将切换到 $TARGET_ENV 环境..."

# 执行蓝绿切换
./blue-green-switch.sh $NAMESPACE $TARGET_ENV

# 验证切换是否成功
NEW_ENV=$(kubectl get service jenkins -n $NAMESPACE -o jsonpath='{.spec.selector.env}')
echo "切换后 Jenkins 服务指向: $NEW_ENV 环境"

if [ "$NEW_ENV" == "$TARGET_ENV" ]; then
  echo "测试成功: 服务成功切换到 $TARGET_ENV 环境"
else
  echo "测试失败: 服务未能切换到 $TARGET_ENV 环境"
  exit 1
fi

# 测试服务是否可访问
echo "测试 Jenkins 服务是否可访问..."
SERVICE_IP=$(kubectl get service jenkins -n $NAMESPACE -o jsonpath='{.status.loadBalancer.ingress[0].ip}')

if [ -z "$SERVICE_IP" ]; then
  echo "警告: 无法获取服务 IP，可能需要等待 LoadBalancer 分配 IP"
  echo "请稍后手动验证服务可访问性"
else
  echo "Jenkins 服务 IP: $SERVICE_IP"
  echo "尝试访问 Jenkins 服务..."
  
  # 等待服务就绪
  echo "等待服务就绪..."
  sleep 10
  
  # 使用 curl 测试服务可访问性
  HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" http://$SERVICE_IP:8080/login || echo "连接失败")
  
  if [[ "$HTTP_CODE" == "200" || "$HTTP_CODE" == "403" ]]; then
    echo "测试成功: Jenkins 服务可访问，HTTP 状态码: $HTTP_CODE"
  else
    echo "测试警告: Jenkins 服务返回非预期状态码: $HTTP_CODE"
    echo "这可能是因为 Jenkins 仍在启动中，请稍后手动验证"
  fi
fi

# 切换回原始环境
echo "切换回 $CURRENT_ENV 环境..."
./blue-green-switch.sh $NAMESPACE $CURRENT_ENV

# 验证切换回原始环境是否成功
FINAL_ENV=$(kubectl get service jenkins -n $NAMESPACE -o jsonpath='{.spec.selector.env}')
echo "最终 Jenkins 服务指向: $FINAL_ENV 环境"

if [ "$FINAL_ENV" == "$CURRENT_ENV" ]; then
  echo "测试成功: 服务成功切换回 $CURRENT_ENV 环境"
else
  echo "测试失败: 服务未能切换回 $CURRENT_ENV 环境"
  exit 1
fi

echo "蓝绿发布测试完成！"
