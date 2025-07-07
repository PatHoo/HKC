/**
 * 蓝环境模块配置
 * 创建日期: 2025-07-08
 */

# 创建蓝环境计算实例
resource "google_compute_instance" "blue" {
  name         = "${var.app_name}-blue"
  machine_type = var.machine_type
  zone         = var.zone
  tags         = ["blue", var.app_name, "http-server"]

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
      size  = 20
    }
  }

  network_interface {
    network    = var.network
    subnetwork = var.subnetwork

    access_config {
      // 临时外部 IP
    }
  }

  metadata = {
    environment = "blue"
    app_name    = var.app_name
    app_version = var.app_version
    is_active   = var.is_active
  }

  metadata_startup_script = <<-EOF
    #!/bin/bash
    apt-get update
    apt-get install -y nginx

    # 创建应用目录
    mkdir -p ${var.deploy_path}/blue

    # 创建版本文件
    echo "${var.app_version}" > ${var.deploy_path}/blue/VERSION

    # 创建示例应用
    cat > ${var.deploy_path}/blue/app.js <<EOL
    const http = require('http');
    const port = ${var.port};
    
    const server = http.createServer((req, res) => {
      if (req.url === '/health') {
        res.statusCode = 200;
        res.setHeader('Content-Type', 'application/json');
        res.end(JSON.stringify({ status: 'healthy', environment: 'blue', version: '${var.app_version}' }));
        return;
      }
      
      res.statusCode = 200;
      res.setHeader('Content-Type', 'text/html');
      res.end('<html><body style="background-color: #3498db; color: white; text-align: center; font-family: Arial, sans-serif;"><h1>蓝环境</h1><p>版本: ${var.app_version}</p><p>状态: ' + (${var.is_active ? "'活动'" : "'非活动'"}) + '</p></body></html>');
    });
    
    server.listen(port, () => {
      console.log('服务器运行在 http://localhost:' + port + '/');
    });
    EOL

    # 安装 Node.js
    apt-get install -y nodejs npm

    # 创建服务文件
    cat > /etc/systemd/system/app-blue.service <<EOL
    [Unit]
    Description=Blue Environment App
    After=network.target
    
    [Service]
    ExecStart=/usr/bin/node ${var.deploy_path}/blue/app.js
    WorkingDirectory=${var.deploy_path}/blue
    Restart=always
    User=root
    Environment=NODE_ENV=production
    
    [Install]
    WantedBy=multi-user.target
    EOL

    # 启用并启动服务
    systemctl enable app-blue
    systemctl start app-blue

    # 创建配置文件
    cat > ${var.deploy_path}/blue/blue.properties <<EOL
    # 蓝环境配置
    DEPLOY_PATH=${var.deploy_path}/blue
    SERVICE_NAME=app-blue
    HEALTH_CHECK_URL=http://localhost:${var.port}/health
    PORT=${var.port}
    ENV_NAME=blue
    DB_NAME=app_db_blue
    CACHE_PREFIX=blue_
    EOL

    echo "蓝环境部署完成，版本 ${var.app_version}"
  EOF

  service_account {
    scopes = ["cloud-platform"]
  }
}

# 创建防火墙规则允许访问蓝环境
resource "google_compute_firewall" "blue_firewall" {
  name    = "${var.app_name}-blue-firewall"
  network = var.network

  allow {
    protocol = "tcp"
    ports    = [var.port]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["blue", var.app_name]
}

# 创建健康检查
resource "google_compute_health_check" "blue_health_check" {
  name               = "${var.app_name}-blue-health-check"
  check_interval_sec = 5
  timeout_sec        = 5
  tcp_health_check {
    port = var.port
  }
}
