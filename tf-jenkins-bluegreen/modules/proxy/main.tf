/**
 * 代理模块配置（Nginx）
 * 创建日期: 2025-07-08
 */

# 创建代理服务器实例
resource "google_compute_instance" "proxy" {
  name         = "${var.app_name}-proxy"
  machine_type = var.machine_type
  zone         = var.zone
  tags         = ["proxy", var.app_name, "http-server"]

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
      size  = 10
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
    app_name    = var.app_name
    active_env  = var.active_env
  }

  metadata_startup_script = <<-EOF
    #!/bin/bash
    apt-get update
    apt-get install -y nginx

    # 创建 Nginx 配置
    cat > /etc/nginx/sites-available/default <<EOL
    # Nginx 蓝绿部署配置
    # 创建日期: 2025-07-08

    upstream blue {
        server ${var.blue_address}:${var.blue_port};
    }

    upstream green {
        server ${var.green_address}:${var.green_port};
    }

    server {
        listen 80;
        server_name _;

        access_log /var/log/nginx/app.access.log;
        error_log /var/log/nginx/app.error.log;

        # 根据当前活动环境转发请求
        location / {
            proxy_pass http://${var.active_env};
            proxy_set_header Host \$host;
            proxy_set_header X-Real-IP \$remote_addr;
            proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto \$scheme;
        }

        # 健康检查端点
        location /health {
            proxy_pass http://${var.active_env}/health;
            proxy_set_header Host \$host;
            proxy_set_header X-Real-IP \$remote_addr;
        }
    }
    EOL

    # 创建环境状态文件
    echo "${var.active_env}" > /var/www/active_env.txt

    # 重启 Nginx
    systemctl restart nginx

    echo "代理服务器配置完成，当前活动环境: ${var.active_env}"
  EOF

  service_account {
    scopes = ["cloud-platform"]
  }
}

# 创建防火墙规则允许 HTTP 访问
resource "google_compute_firewall" "proxy_firewall" {
  name    = "${var.app_name}-proxy-firewall"
  network = var.network

  allow {
    protocol = "tcp"
    ports    = ["80", "443"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["proxy", var.app_name]
}
