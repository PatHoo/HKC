# HKC
Terraform for GCP

## 子项目列表

本仓库包含以下子项目：

1. **tf-gcp-hpa** - 使用 Terraform 在 GCP 上实现 Kubernetes 的 Horizontal Pod Autoscaler (HPA) 功能
   - 创建 GKE 集群
   - 部署示例应用
   - 配置 HPA 自动扩缩容
   - 支持基于 CPU 和内存使用率的扩缩容
   - [查看架构图](./tf-gcp-hpa/README.md#架构图)

2. **tf-jenkins-bluegreen** - 在 Jenkins 上实现简单的蓝绿部署方案
   - 完整的 Jenkins 流水线
   - 自动化的部署、测试、切换流程
   - 支持一键回滚
   - 基于 Nginx 的流量切换
   - [查看架构图](./tf-jenkins-bluegreen/README.md#架构图)

## 使用说明

每个子项目都有自己的 README.md 文件，包含详细的使用说明和配置指南。请参考各子项目目录中的文档。
