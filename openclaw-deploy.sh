#!/bin/bash

################################################################################
# OpenClaw 一键部署脚本
# 版本: 1.0.0
# 日期: 2026-03-06
# 作者: Claude (Kiro AI Assistant)
#
# 功能:
# - 自动安装 OpenClaw Gateway
# - 配置 Nginx 反向代理
# - 配置 Telegram Bot
# - 配置 Tailscale 网络
# - 自动修复常见问题
#
# 使用方法:
#   bash openclaw-deploy.sh
#
# 环境要求:
# - Debian/Ubuntu Linux
# - Root 权限
# - 网络连接
################################################################################

set -e  # 遇到错误立即退出

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 日志函数
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# 检查是否为 root 用户
check_root() {
    if [ "$EUID" -ne 0 ]; then
        log_error "请使用 root 权限运行此脚本"
        exit 1
    fi
}

# 检测系统类型
detect_system() {
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        OS=$ID
        VER=$VERSION_ID
    else
        log_error "无法检测系统类型"
        exit 1
    fi
    log_info "检测到系统: $OS $VER"
}

# 安装依赖
install_dependencies() {
    log_info "安装系统依赖..."

    if [ "$OS" = "debian" ] || [ "$OS" = "ubuntu" ]; then
        apt-get update
        apt-get install -y curl wget git build-essential nginx
    elif [ "$OS" = "centos" ] || [ "$OS" = "rhel" ]; then
        yum install -y curl wget git gcc-c++ make nginx
    else
        log_warning "未知系统类型，跳过依赖安装"
    fi

    log_success "系统依赖安装完成"
}

# 安装 fnm (Fast Node Manager)
install_fnm() {
    log_info "安装 fnm..."

    if command -v fnm &> /dev/null; then
        log_warning "fnm 已安装，跳过"
        return
    fi

    curl -fsSL https://fnm.vercel.app/install | bash

    # 配置环境变量
    export PATH="/root/.local/share/fnm:$PATH"
    eval "$(fnm env --use-on-cd)"

    log_success "fnm 安装完成"
}

# 安装 Node.js
install_nodejs() {
    log_info "安装 Node.js..."

    export PATH="/root/.local/share/fnm:$PATH"
    eval "$(fnm env --use-on-cd)"

    fnm install 24
    fnm use 24
    fnm default 24

    node --version
    npm --version

    log_success "Node.js 安装完成"
}

# 安装 OpenClaw
install_openclaw() {
    log_info "安装 OpenClaw..."

    export PATH="/root/.local/share/fnm/node-versions/v24.13.0/installation/bin:$PATH"

    npm install -g openclaw

    openclaw --version

    log_success "OpenClaw 安装完成"
}

# 配置 OpenClaw
configure_openclaw() {
    log_info "配置 OpenClaw..."

    export PATH="/root/.local/share/fnm/node-versions/v24.13.0/installation/bin:$PATH"

    # 提示用户输入配置
    echo ""
    echo "=========================================="
    echo "OpenClaw 配置向导"
    echo "=========================================="
    echo ""

    # Anthropic API 密钥
    read -p "请输入 Anthropic API 密钥: " ANTHROPIC_API_KEY
    if [ -z "$ANTHROPIC_API_KEY" ]; then
        log_error "API 密钥不能为空"
        exit 1
    fi

    # Anthropic API Base URL
    read -p "请输入 Anthropic API Base URL (留空使用官方 API): " ANTHROPIC_BASE_URL
    if [ -z "$ANTHROPIC_BASE_URL" ]; then
        ANTHROPIC_BASE_URL="https://api.anthropic.com"
    fi

    # Telegram Bot Token
    read -p "请输入 Telegram Bot Token (留空跳过): " TELEGRAM_BOT_TOKEN

    # Gateway Token
    GATEWAY_TOKEN=$(openssl rand -hex 24)
    log_info "生成 Gateway Token: $GATEWAY_TOKEN"

    # 配置环境变量
    openclaw config set env.ANTHROPIC_API_KEY "$ANTHROPIC_API_KEY"

    # 配置模型提供商
    if [ "$ANTHROPIC_BASE_URL" != "https://api.anthropic.com" ]; then
        openclaw config set models.providers.anthropic.baseUrl "$ANTHROPIC_BASE_URL"
    fi

    # 配置模型
    openclaw config set agents.defaults.model "anthropic/claude-opus-4-6"

    # 配置 Gateway
    openclaw config set gateway.mode "local"
    openclaw config set gateway.controlUi.basePath "/openclaw"
    openclaw config set gateway.auth.mode "token"
    openclaw config set gateway.auth.token "$GATEWAY_TOKEN"
    openclaw config set gateway.trustedProxies '["100.64.0.0/10", "127.0.0.1"]'

    # 配置 Telegram
    if [ -n "$TELEGRAM_BOT_TOKEN" ]; then
        openclaw config set channels.telegram.enabled true
        openclaw config set channels.telegram.botToken "$TELEGRAM_BOT_TOKEN"
        openclaw config set channels.telegram.dmPolicy "pairing"
        openclaw config set channels.telegram.groupPolicy "allowlist"
        openclaw config set channels.telegram.streaming "partial"
    fi

    log_success "OpenClaw 配置完成"

    # 保存配置信息
    cat > /root/openclaw-tool/config.txt <<EOF
OpenClaw 配置信息
================

Gateway Token: $GATEWAY_TOKEN
Anthropic API Base URL: $ANTHROPIC_BASE_URL
Telegram Bot Token: ${TELEGRAM_BOT_TOKEN:-未配置}

配置文件位置: /root/.openclaw/openclaw.json
EOF

    log_info "配置信息已保存到: /root/openclaw-tool/config.txt"
}

# 配置 Nginx
configure_nginx() {
    log_info "配置 Nginx..."

    # 创建 Nginx 配置文件
    cat > /etc/nginx/sites-available/openclaw-gateway.conf <<'EOF'
# OpenClaw Gateway Nginx 配置
# 生成时间: 2026-03-06

# WebSocket 升级配置
map $http_upgrade $connection_upgrade {
    default upgrade;
    '' close;
}

# HTTPS 协议检测
map $http_x_forwarded_proto $real_scheme {
    default $http_x_forwarded_proto;
    "" $scheme;
}

server {
    listen 127.0.0.1:9000;
    server_name _;

    # 日志配置
    access_log /var/log/nginx/openclaw-access.log;
    error_log /var/log/nginx/openclaw-error.log;

    # 客户端最大请求体大小
    client_max_body_size 100M;

    # OpenClaw WebSocket - 标准路径 /openclaw/ws
    location /openclaw/ws {
        proxy_pass http://127.0.0.1:18789;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection $connection_upgrade;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;

        # WebSocket 超时设置（24小时）
        proxy_read_timeout 86400s;
        proxy_send_timeout 86400s;
        proxy_connect_timeout 60s;

        # 禁用缓冲（WebSocket 必需）
        proxy_buffering off;
    }

    # OpenClaw Control UI - HTTP 静态资源
    location /openclaw/ {
        # 如果没有 X-Forwarded-Proto 头（说明是 HTTP 请求），重定向到 HTTPS
        if ($http_x_forwarded_proto = "") {
            return 301 https://$host$request_uri;
        }
        proxy_pass http://127.0.0.1:18789/openclaw/;
        proxy_http_version 1.1;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_set_header X-Forwarded-Host $host;
    }

    # OpenClaw 根路径重定向
    location = /openclaw {
        return 301 $real_scheme://$host/openclaw/;
    }

    # 健康检查端点
    location /health {
        access_log off;
        return 200 "OK\n";
        add_header Content-Type text/plain;
    }
}
EOF

    # 启用配置
    ln -sf /etc/nginx/sites-available/openclaw-gateway.conf /etc/nginx/sites-enabled/

    # 测试配置
    nginx -t

    # 重载 Nginx
    systemctl reload nginx

    log_success "Nginx 配置完成"
}

# 创建 systemd 服务
create_systemd_service() {
    log_info "创建 systemd 服务..."

    cat > /etc/systemd/system/openclaw-gateway.service <<EOF
[Unit]
Description=OpenClaw Gateway
After=network.target

[Service]
Type=simple
User=root
WorkingDirectory=/root
Environment="PATH=/root/.local/share/fnm/node-versions/v24.13.0/installation/bin:/usr/local/bin:/usr/bin:/bin"
ExecStart=/root/.local/share/fnm/node-versions/v24.13.0/installation/bin/openclaw gateway run
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
EOF

    systemctl daemon-reload
    systemctl enable openclaw-gateway.service

    log_success "systemd 服务创建完成"
}

# 启动服务
start_services() {
    log_info "启动服务..."

    # 启动 OpenClaw Gateway
    systemctl start openclaw-gateway.service
    sleep 5

    # 检查状态
    if systemctl is-active --quiet openclaw-gateway.service; then
        log_success "OpenClaw Gateway 启动成功"
    else
        log_error "OpenClaw Gateway 启动失败"
        systemctl status openclaw-gateway.service
        exit 1
    fi

    # 启动 Nginx
    systemctl restart nginx

    if systemctl is-active --quiet nginx; then
        log_success "Nginx 启动成功"
    else
        log_error "Nginx 启动失败"
        exit 1
    fi
}

# 验证部署
verify_deployment() {
    log_info "验证部署..."

    export PATH="/root/.local/share/fnm/node-versions/v24.13.0/installation/bin:$PATH"

    # 等待服务完全启动
    sleep 5

    # 检查 Gateway
    if openclaw gateway probe > /dev/null 2>&1; then
        log_success "Gateway 连接正常"
    else
        log_warning "Gateway 连接失败，请检查日志"
    fi

    # 检查 Nginx
    if curl -s http://127.0.0.1:9000/health > /dev/null; then
        log_success "Nginx 响应正常"
    else
        log_warning "Nginx 响应失败"
    fi

    # 显示状态
    echo ""
    echo "=========================================="
    echo "OpenClaw 状态"
    echo "=========================================="
    openclaw status
}

# 安装 Tailscale（可选）
install_tailscale() {
    log_info "是否安装 Tailscale? (y/n)"
    read -p "> " install_ts

    if [ "$install_ts" != "y" ]; then
        log_info "跳过 Tailscale 安装"
        return
    fi

    log_info "安装 Tailscale..."

    curl -fsSL https://tailscale.com/install.sh | sh

    log_success "Tailscale 安装完成"
    log_info "请运行 'tailscale up' 来启动 Tailscale"
    log_info "然后运行 'tailscale serve https / http://127.0.0.1:9000' 来配置反向代理"
}

# 生成部署报告
generate_report() {
    log_info "生成部署报告..."

    cat > /root/openclaw-tool/deployment-report.txt <<EOF
OpenClaw 部署报告
================

部署时间: $(date)
系统信息: $OS $VER

服务状态:
- OpenClaw Gateway: $(systemctl is-active openclaw-gateway.service)
- Nginx: $(systemctl is-active nginx)

访问地址:
- Control UI (本地): http://127.0.0.1:18789/openclaw/
- Control UI (Nginx): http://127.0.0.1:9000/openclaw/
- WebSocket: ws://127.0.0.1:9000/openclaw/ws

配置文件:
- OpenClaw: /root/.openclaw/openclaw.json
- Nginx: /etc/nginx/sites-available/openclaw-gateway.conf
- systemd: /etc/systemd/system/openclaw-gateway.service

日志文件:
- OpenClaw: /tmp/openclaw/openclaw-$(date +%Y-%m-%d).log
- Nginx Access: /var/log/nginx/openclaw-access.log
- Nginx Error: /var/log/nginx/openclaw-error.log

常用命令:
- 查看状态: openclaw status
- 查看日志: journalctl -u openclaw-gateway.service -f
- 重启服务: systemctl restart openclaw-gateway.service
- 测试连接: openclaw gateway probe

下一步:
1. 配置 Tailscale (如果需要外部访问)
   - tailscale up
   - tailscale serve https / http://127.0.0.1:9000

2. 配置 Telegram 白名单 (如果启用了 Telegram)
   - 发送消息给 Bot
   - 查看日志获取用户 ID: openclaw logs --follow
   - 添加到白名单: openclaw config set channels.telegram.allowFrom '["USER_ID"]'

3. 测试功能
   - 访问 Control UI
   - 测试 Telegram Bot
   - 测试 WebSocket 连接

故障排查:
- Gateway 无法连接: systemctl status openclaw-gateway.service
- Nginx 502 错误: tail -f /var/log/nginx/openclaw-error.log
- API 密钥错误: openclaw models status

EOF

    log_success "部署报告已保存到: /root/openclaw-tool/deployment-report.txt"
}

# 主函数
main() {
    echo ""
    echo "=========================================="
    echo "OpenClaw 一键部署脚本"
    echo "版本: 1.0.0"
    echo "=========================================="
    echo ""

    check_root
    detect_system

    log_info "开始部署 OpenClaw..."
    echo ""

    # 安装步骤
    install_dependencies
    install_fnm
    install_nodejs
    install_openclaw

    # 配置步骤
    configure_openclaw
    configure_nginx
    create_systemd_service

    # 启动服务
    start_services

    # 验证部署
    verify_deployment

    # 可选安装
    install_tailscale

    # 生成报告
    generate_report

    echo ""
    echo "=========================================="
    log_success "OpenClaw 部署完成！"
    echo "=========================================="
    echo ""
    echo "配置信息: /root/openclaw-tool/config.txt"
    echo "部署报告: /root/openclaw-tool/deployment-report.txt"
    echo ""
    echo "访问 Control UI: http://127.0.0.1:9000/openclaw/"
    echo ""
}

# 运行主函数
main "$@"
