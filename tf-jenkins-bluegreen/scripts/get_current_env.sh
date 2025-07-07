#!/bin/bash
# 获取当前活动环境（蓝或绿）
# 创建日期: 2025-07-07

# 环境文件路径
ENV_FILE="/var/jenkins_home/blue_green_current_env"

# 如果环境文件不存在，默认为蓝环境
if [ ! -f "$ENV_FILE" ]; then
    echo "blue" > "$ENV_FILE"
    echo "blue"
    exit 0
fi

# 读取当前环境
CURRENT_ENV=$(cat "$ENV_FILE")

# 验证环境值
if [ "$CURRENT_ENV" != "blue" ] && [ "$CURRENT_ENV" != "green" ]; then
    echo "blue" > "$ENV_FILE"
    echo "blue"
    exit 0
fi

# 输出当前环境
echo "$CURRENT_ENV"
exit 0
