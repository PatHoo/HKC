#!/bin/bash

# 蓝绿发布切换脚本
# 用法: ./blue-green-switch.sh <namespace> <active-color>

set -e

NAMESPACE=$1
ACTIVE_COLOR=$2

if [ -z "$NAMESPACE" ] || [ -z "$ACTIVE_COLOR" ]; then
  echo "用法: ./blue-green-switch.sh <namespace> <active-color>"
  echo "例如: ./blue-green-switch.sh jenkins blue"
  exit 1
fi

if [ "$ACTIVE_COLOR" != "blue" ] && [ "$ACTIVE_COLOR" != "green" ]; then
  echo "错误: active-color 必须是 'blue' 或 'green'"
  exit 1
fi

echo "切换主要流量到 $ACTIVE_COLOR 环境..."

# 获取当前主服务的选择器
CURRENT_SELECTOR=$(kubectl get service jenkins -n $NAMESPACE -o jsonpath='{.spec.selector}')
echo "当前选择器: $CURRENT_SELECTOR"

# 更新主服务以指向活动颜色
kubectl patch service jenkins -n $NAMESPACE --type=json -p "[
  {
    \"op\": \"replace\",
    \"path\": \"/spec/selector\",
    \"value\": {
      \"app\": \"jenkins\",
      \"env\": \"$ACTIVE_COLOR\"
    }
  }
]"

echo "服务已更新，现在指向 $ACTIVE_COLOR 环境"
echo "验证新的选择器..."
NEW_SELECTOR=$(kubectl get service jenkins -n $NAMESPACE -o jsonpath='{.spec.selector}')
echo "新选择器: $NEW_SELECTOR"

echo "完成！主流量现在指向 $ACTIVE_COLOR 环境"
