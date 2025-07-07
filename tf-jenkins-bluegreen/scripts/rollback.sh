#!/bin/bash
# 回滚到上一个环境
# 创建日期: 2025-07-07

# 检查参数
if [ $# -lt 2 ]; then
    echo "用法: $0 <当前环境> <目标环境>"
    echo "例如: $0 green blue"
    exit 1
fi

# 获取参数
CURRENT_ENV=$1
TARGET_ENV=$2

echo "开始回滚，将流量从 $CURRENT_ENV 环境切换回 $TARGET_ENV 环境..."

# 定义 Nginx 配置文件路径（根据实际情况修改）
NGINX_CONFIG="/etc/nginx/conf.d/app.conf"
NGINX_CONFIG_TEMPLATE="/etc/nginx/conf.d/app.conf.template"

# 检查 Nginx 配置文件是否存在
if [ ! -f "$NGINX_CONFIG_TEMPLATE" ]; then
    echo "错误: Nginx 配置模板文件不存在: $NGINX_CONFIG_TEMPLATE"
    exit 1
fi

# 根据目标环境生成 Nginx 配置
echo "生成 Nginx 配置..."

# 替换配置模板中的环境变量
sed "s/{{ACTIVE_ENV}}/$TARGET_ENV/g" $NGINX_CONFIG_TEMPLATE > $NGINX_CONFIG

# 检查配置是否有效
echo "验证 Nginx 配置..."
nginx -t

if [ $? -ne 0 ]; then
    echo "错误: Nginx 配置无效"
    exit 1
fi

# 重新加载 Nginx 配置
echo "重新加载 Nginx 配置..."
nginx -s reload

if [ $? -ne 0 ]; then
    echo "错误: 无法重新加载 Nginx 配置"
    exit 1
fi

echo "已成功回滚到 $TARGET_ENV 环境"

# 更新当前活动环境记录
echo "$TARGET_ENV" > "/var/jenkins_home/blue_green_current_env"

exit 0
