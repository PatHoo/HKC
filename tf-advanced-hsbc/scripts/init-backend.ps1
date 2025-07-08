param(
    [Parameter(Mandatory=$true, HelpMessage="Environment name (dev, stage, prod)")]
    [ValidateSet("dev", "stage", "prod")]
    [string]$Environment,
    
    [Parameter(Mandatory=$true, HelpMessage="GCP Project ID")]
    [string]$ProjectId,
    
    [Parameter(HelpMessage="GCP Region")]
    [string]$Region = "asia-east1",
    
    [Parameter(HelpMessage="Service Account ID for Terraform")]
    [string]$ServiceAccountId = "terraform"
)

# 设置错误处理
$ErrorActionPreference = "Stop"

# 获取脚本所在目录
$scriptPath = Split-Path -Parent $MyInvocation.MyCommand.Path
$rootPath = Join-Path $scriptPath ".." -Resolve

# 设置环境目录路径
$envDir = Join-Path $rootPath "environments\$Environment"
$templatesDir = Join-Path $rootPath "environments\_templates"

# 创建环境目录（如果不存在）
if (-not (Test-Path $envDir)) {
    Write-Host "Creating environment directory: $envDir" -ForegroundColor Cyan
    New-Item -ItemType Directory -Path $envDir -Force | Out-Null
}

# 确保模板目录存在
if (-not (Test-Path $templatesDir)) {
    Write-Host "Creating templates directory: $templatesDir" -ForegroundColor Cyan
    New-Item -ItemType Directory -Path $templatesDir -Force | Out-Null
}

# 确保 backend 模板存在
$backendTemplatePath = Join-Path $templatesDir "backend.tf.tpl"
if (-not (Test-Path $backendTemplatePath)) {
    # 如果模板不存在，创建一个默认的
    @"
terraform {
  backend "gcs" {
    bucket = "`${project_id}-tfstate"
    prefix = "`${environment}/state"
  }
}
"@ | Out-File -FilePath $backendTemplatePath -Encoding utf8 -Force
    Write-Host "Created default backend template at: $backendTemplatePath" -ForegroundColor Yellow
}

# 生成 backend.tf
$backendTemplate = Get-Content -Path $backendTemplatePath -Raw -ErrorAction Stop
$backendConfig = $backendTemplate -replace '\$\{project_id\}', $ProjectId `
                                -replace '\$\{environment\}', $Environment

# 创建 terraform.tfvars 文件（如果不存在）
# 创建 terraform.tfvars 文件（如果不存在）
$tfVarsPath = Join-Path $envDir "terraform.tfvars"
if (-not (Test-Path $tfVarsPath)) {
    Write-Host "Creating terraform.tfvars file: $tfVarsPath" -ForegroundColor Cyan
    @"
project_id = "$ProjectId"
region = "$Region"
environment = "$Environment"
    
# 根据需要添加其他变量
# 示例:
# cluster_name = "gke-$Environment"
# node_count = 2
"@ | Out-File -FilePath $tfVarsPath -Encoding utf8
}

# 创建 versions.tf 文件（如果不存在）
$versionsPath = Join-Path $envDir "versions.tf"
if (-not (Test-Path $versionsPath)) {
    Write-Host "Creating versions.tf file: $versionsPath" -ForegroundColor Cyan
    @"
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
"@ | Out-File -FilePath $versionsPath -Encoding utf8
}

# 创建 main.tf 文件（如果不存在）
$mainTfPath = Join-Path $envDir "main.tf"
if (-not (Test-Path $mainTfPath)) {
    Write-Host "Creating main.tf file: $mainTfPath" -ForegroundColor Cyan
    @"
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
"@ | Out-File -FilePath $mainTfPath -Encoding utf8
}

# 创建 backend.tf 文件
$backendTfPath = Join-Path $envDir "backend.tf"
Write-Host "Creating/updating backend.tf: $backendTfPath" -ForegroundColor Cyan
$backendConfig | Out-File -FilePath $backendTfPath -Encoding utf8 -Force

try {
    # 切换到环境目录
    Push-Location $envDir
    
    # 初始化 Terraform
    Write-Host "`n正在为 $Environment 环境初始化 Terraform..." -ForegroundColor Green
    terraform init -input=false
    
    Write-Host "`n环境 '$Environment' 已成功初始化！" -ForegroundColor Green
    Write-Host "后续步骤：" -ForegroundColor Yellow
    Write-Host "1. 检查并更新配置文件: $((Resolve-Path $tfVarsPath).Path)"
    Write-Host "2. 运行 'terraform plan' 查看执行计划"
    Write-Host "3. 运行 'terraform apply' 应用配置"
}
catch {
    Write-Error "初始化过程中出错: $_" -ErrorAction Continue
    exit 1
}
finally {
    # 确保总是返回到原始目录
    Pop-Location
}
