#!/bin/bash

################################################################################
# OpenClaw macOS 部署脚本
# 版本: 2.1.0
# 日期: 2026-03-06
# 作者: Claude (Kiro AI Assistant)
#
# 功能:
# - 自动安装 OpenClaw Gateway
# - 配置 Nginx 反向代理
# - 配置 Telegram Bot
# - 配置 Tailscale 网络
# - 配置 Gateway allowedOrigins
# - 使用 launchd 管理服务
#
# 使用方法:
#   bash openclaw-deploy-macos.sh
#
# 环境要求:
# - macOS 10.15+
# - 管理员权限
# - 网络连接
################################################################################

# 错误处理
set -o pipefail

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# 全局变量
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
NODE_PATH=""
NGINX_CONF_DIR="/usr/local/etc/nginx/servers"
DEPLOYMENT_FAILED=0
CURRENT_USER=$(whoami)
USER_HOME=$(eval echo ~$CURRENT_USER)

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

# 清理函数
cleanup_on_error() {
    if [ $DEPLOYMENT_FAILED -eq 1 ]; then
        log_error "部署失败，正在清理..."
    fi
}

trap cleanup_on_error EXIT

# 检查是否为 macOS
check_macos() {
    if [[ "$OSTYPE" != "darwin"* ]]; then
        log_error "此脚本仅支持 macOS"
        log_info "Linux 用户请使用: openclaw-deploy.sh"
        exit 1
    fi
    log_success "macOS 系统检查通过"
}

# 检查网络连接
check_network() {
    log_info "检查网络连接..."
    
    if ! ping -c 1 -W 3 8.8.8.8 &> /dev/null; then
        log_error "网络连接失败，请检查网络设置"
        exit 1
    fi
    
    log_success "网络连接正常"
}

# 检查并安装 Homebrew
install_homebrew() {
    log_info "检查 Homebrew..."
    
    if command -v brew &> /dev/null; then
        log_success "Homebrew 已安装"
        return 0
    fi
    
    log_info "安装 Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" || {
        log_error "Homebrew 安装失败"
        DEPLOYMENT_FAILED=1
        exit 1
    }
    
    # 配置 Homebrew 环境变量
    if [[ $(uname -m) == "arm64" ]]; then
        eval "$(/opt/homebrew/bin/brew shellenv)"
    else
        eval "$(/usr/local/bin/brew shellenv)"
    fi
    
    log_success "Homebrew 安装完成"
}

# 安装依赖
install_dependencies() {
    log_info "安装系统依赖..."
    
    brew update || {
        log_error "brew update 失败"
        DEPLOYMENT_FAILED=1
        exit 1
    }
    
    # 安装依赖包
    brew install curl wget git nginx jq || {
        log_error "依赖安装失败"
        DEPLOYMENT_FAILED=1
        exit 1
    }
    
    log_success "系统依赖安装完成"
}

# 创建必要的目录
create_directories() {
    log_info "创建必要的目录..."
    
    # 创建 Nginx 配置目录
    mkdir -p "$NGINX_CONF_DIR" || {
        log_error "无法创建 Nginx 配置目录: $NGINX_CONF_DIR"
        DEPLOYMENT_FAILED=1
        exit 1
    }
    
    # 创建工具目录
    mkdir -p "$SCRIPT_DIR" || {
        log_error "无法创建工具目录: $SCRIPT_DIR"
        DEPLOYMENT_FAILED=1
        exit 1
    }
    
    # 创建 LaunchAgents 目录
    mkdir -p "$USER_HOME/Library/LaunchAgents" || {
        log_error "无法创建 LaunchAgents 目录"
        DEPLOYMENT_FAILED=1
        exit 1
    }
    
    log_success "目录创建完成"
}

# 安装 fnm (Fast Node Manager)
install_fnm() {
    log_info "安装 fnm..."
    
    if command -v fnm &> /dev/null; then
        log_warning "fnm 已安装，跳过"
        return 0
    fi
    
    curl -fsSL https://fnm.vercel.app/install | bash || {
        log_error "fnm 安装失败"
        DEPLOYMENT_FAILED=1
        exit 1
    }
    
    # 配置环境变量
    export PATH="$USER_HOME/.local/share/fnm:$PATH"
    eval "$(fnm env --use-on-cd)" || true
    
    log_success "fnm 安装完成"
}

# 安装 Node.js
install_nodejs() {
    log_info "安装 Node.js..."
    
    export PATH="$USER_HOME/.local/share/fnm:$PATH"
    eval "$(fnm env --use-on-cd)" || true
    
    fnm install 24 || {
        log_error "Node.js 安装失败"
        DEPLOYMENT_FAILED=1
        exit 1
    }
    
    fnm use 24 || {
        log_error "Node.js 切换失败"
        DEPLOYMENT_FAILED=1
        exit 1
    }
    
    fnm default 24 || {
        log_error "Node.js 设置默认版本失败"
        DEPLOYMENT_FAILED=1
        exit 1
    }
    
    # 动态获取 Node.js 路径
    NODE_PATH=$(fnm current | xargs -I {} find "$USER_HOME/.local/share/fnm/node-versions" -name "v{}*" -type d | head -1)
    if [ -z "$NODE_PATH" ]; then
        log_error "无法获取 Node.js 路径"
        DEPLOYMENT_FAILED=1
        exit 1
    fi
    
    export PATH="$NODE_PATH/installation/bin:$PATH"
    
    node --version || {
        log_error "Node.js 验证失败"
        DEPLOYMENT_FAILED=1
        exit 1
    }
    
    npm --version || {
        log_error "npm 验证失败"
        DEPLOYMENT_FAILED=1
        exit 1
    }
    
    log_success "Node.js 安装完成 (路径: $NODE_PATH)"
}

# 安装 OpenClaw
install_openclaw() {
    log_info "安装 OpenClaw..."
    
    export PATH="$NODE_PATH/installation/bin:$PATH"
    
    # macOS 特殊处理：设置 SHARP_IGNORE_GLOBAL_LIBVIPS
    export SHARP_IGNORE_GLOBAL_LIBVIPS=1
    
    npm install -g openclaw || {
        log_error "OpenClaw 安装失败"
        DEPLOYMENT_FAILED=1
        exit 1
    }
    
    openclaw --version || {
        log_error "OpenClaw 验证失败"
        DEPLOYMENT_FAILED=1
        exit 1
    }
    
    log_success "OpenClaw 安装完成"
}


# 配置 OpenClaw
configure_openclaw() {
    log_info "配置 OpenClaw..."
    
    export PATH="$NODE_PATH/installation/bin:$PATH"
    
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
        DEPLOYMENT_FAILED=1
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
    openclaw config set env.ANTHROPIC_API_KEY "$ANTHROPIC_API_KEY" || {
        log_error "配置 API 密钥失败"
        DEPLOYMENT_FAILED=1
        exit 1
    }
    
    # 配置模型提供商
    if [ "$ANTHROPIC_BASE_URL" != "https://api.anthropic.com" ]; then
        openclaw config set models.providers.anthropic.baseUrl "$ANTHROPIC_BASE_URL" || {
            log_warning "配置 Base URL 失败"
        }
    fi
    
    # 配置模型
    openclaw config set agents.defaults.model "anthropic/claude-opus-4-6" || {
        log_warning "配置模型失败"
    }
    
    # 配置 Gateway
    openclaw config set gateway.mode "local" || log_warning "配置 gateway.mode 失败"
    openclaw config set gateway.controlUi.basePath "/openclaw" || log_warning "配置 basePath 失败"
    openclaw config set gateway.auth.mode "token" || log_warning "配置 auth.mode 失败"
    openclaw config set gateway.auth.token "$GATEWAY_TOKEN" || log_warning "配置 token 失败"
    openclaw config set gateway.trustedProxies '["100.64.0.0/10", "127.0.0.1"]' || log_warning "配置 trustedProxies 失败"
    
    # 配置 Telegram
    if [ -n "$TELEGRAM_BOT_TOKEN" ]; then
        openclaw config set channels.telegram.enabled true || log_warning "启用 Telegram 失败"
        openclaw config set channels.telegram.botToken "$TELEGRAM_BOT_TOKEN" || log_warning "配置 Telegram token 失败"
        openclaw config set channels.telegram.dmPolicy "pairing" || log_warning "配置 dmPolicy 失败"
        openclaw config set channels.telegram.groupPolicy "allowlist" || log_warning "配置 groupPolicy 失败"
        openclaw config set channels.telegram.streaming "partial" || log_warning "配置 streaming 失败"
    fi
    
    log_success "OpenClaw 配置完成"
    
    # 保存配置信息
    cat > "$SCRIPT_DIR/config.txt" <<EOF
OpenClaw 配置信息
================

Gateway Token: $GATEWAY_TOKEN
Anthropic API Base URL: $ANTHROPIC_BASE_URL
Telegram Bot Token: ${TELEGRAM_BOT_TOKEN:-未配置}

配置文件位置: $USER_HOME/.openclaw/openclaw.json
EOF
    
    log_info "配置信息已保存到: $SCRIPT_DIR/config.txt"
}

# 配置 Nginx
configure_nginx() {
    log_info "配置 Nginx..."
    
    NGINX_CONF_FILE="$NGINX_CONF_DIR/openclaw-gateway.conf"
    
    # 创建 Nginx 配置文件
    cat > "$NGINX_CONF_FILE" <<'EOF'
# OpenClaw Gateway Nginx 配置 (macOS)
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
    access_log /usr/local/var/log/nginx/openclaw-access.log;
    error_log /usr/local/var/log/nginx/openclaw-error.log;

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

    if [ $? -ne 0 ]; then
        log_error "创建 Nginx 配置文件失败"
        DEPLOYMENT_FAILED=1
        exit 1
    fi
    
    # 测试配置
    nginx -t || {
        log_error "Nginx 配置测试失败"
        DEPLOYMENT_FAILED=1
        exit 1
    }
    
    # 启动或重载 Nginx
    if brew services list | grep nginx | grep started &> /dev/null; then
        brew services restart nginx || {
            log_error "Nginx 重启失败"
            DEPLOYMENT_FAILED=1
            exit 1
        }
    else
        brew services start nginx || {
            log_error "Nginx 启动失败"
            DEPLOYMENT_FAILED=1
            exit 1
        }
    fi
    
    log_success "Nginx 配置完成"
}


# 创建 launchd 服务
create_launchd_service() {
    log_info "创建 launchd 服务..."
    
    if [ -z "$NODE_PATH" ]; then
        log_error "Node.js 路径未设置"
        DEPLOYMENT_FAILED=1
        exit 1
    fi
    
    PLIST_FILE="$USER_HOME/Library/LaunchAgents/com.openclaw.gateway.plist"
    
    cat > "$PLIST_FILE" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>com.openclaw.gateway</string>
    
    <key>ProgramArguments</key>
    <array>
        <string>$NODE_PATH/installation/bin/openclaw</string>
        <string>gateway</string>
        <string>run</string>
    </array>
    
    <key>WorkingDirectory</key>
    <string>$USER_HOME</string>
    
    <key>EnvironmentVariables</key>
    <dict>
        <key>PATH</key>
        <string>$NODE_PATH/installation/bin:/usr/local/bin:/usr/bin:/bin</string>
    </dict>
    
    <key>RunAtLoad</key>
    <true/>
    
    <key>KeepAlive</key>
    <true/>
    
    <key>StandardOutPath</key>
    <string>$USER_HOME/Library/Logs/openclaw-gateway.log</string>
    
    <key>StandardErrorPath</key>
    <string>$USER_HOME/Library/Logs/openclaw-gateway-error.log</string>
</dict>
</plist>
EOF

    if [ $? -ne 0 ]; then
        log_error "创建 launchd 服务文件失败"
        DEPLOYMENT_FAILED=1
        exit 1
    fi
    
    # 设置正确的权限
    chmod 644 "$PLIST_FILE"
    
    log_success "launchd 服务创建完成"
}

# 启动服务
start_services() {
    log_info "启动服务..."
    
    PLIST_FILE="$USER_HOME/Library/LaunchAgents/com.openclaw.gateway.plist"
    
    # 卸载旧服务（如果存在）
    launchctl unload "$PLIST_FILE" 2>/dev/null || true
    
    # 加载新服务
    launchctl load "$PLIST_FILE" || {
        log_error "OpenClaw Gateway 启动失败"
        DEPLOYMENT_FAILED=1
        exit 1
    }
    
    sleep 5
    
    # 检查状态
    if launchctl list | grep com.openclaw.gateway &> /dev/null; then
        log_success "OpenClaw Gateway 启动成功"
    else
        log_error "OpenClaw Gateway 启动失败"
        DEPLOYMENT_FAILED=1
        exit 1
    fi
    
    # 检查 Nginx
    if brew services list | grep nginx | grep started &> /dev/null; then
        log_success "Nginx 运行正常"
    else
        log_error "Nginx 未运行"
        DEPLOYMENT_FAILED=1
        exit 1
    fi
}

# 验证部署
verify_deployment() {
    log_info "验证部署..."
    
    export PATH="$NODE_PATH/installation/bin:$PATH"
    
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
    openclaw status || log_warning "无法获取 OpenClaw 状态"
}

# 安装 Tailscale（可选）
install_tailscale() {
    log_info "是否配置 Tailscale? (y/n)"
    read -p "> " install_ts
    
    if [ "$install_ts" != "y" ]; then
        log_info "跳过 Tailscale 配置"
        return 0
    fi
    
    # 检查 Tailscale 是否已安装
    if ! command -v tailscale &> /dev/null; then
        log_info "Tailscale 未安装，正在安装..."
        brew install tailscale || {
            log_error "Tailscale 安装失败"
            return 1
        }
        log_success "Tailscale 安装完成"
        log_info "请在系统偏好设置中启动 Tailscale，然后重新运行此脚本配置路由"
        return 0
    else
        log_info "Tailscale 已安装"
    fi
    
    # 检查 Tailscale 是否运行
    if ! tailscale status &> /dev/null; then
        log_warning "Tailscale 未运行"
        log_info "请在系统偏好设置中启动 Tailscale"
        return 0
    fi
    
    log_info "配置 Tailscale Serve 路由..."
    
    # 重置现有配置
    log_info "重置现有 Tailscale Serve 配置..."
    tailscale serve reset 2>/dev/null || true
    
    # 配置 HTTPS (443) 代理到 Nginx
    log_info "配置 HTTPS (443) → Nginx (9000)..."
    tailscale serve --bg http://127.0.0.1:9000 || {
        log_error "配置 HTTPS 路由失败"
        return 1
    }
    
    # 配置 HTTP (80) 代理到 Nginx
    log_info "配置 HTTP (80) → Nginx (9000)..."
    tailscale serve --http=80 --bg http://127.0.0.1:9000 || {
        log_error "配置 HTTP 路由失败"
        return 1
    }
    
    # 检查 jq 是否可用
    if ! command -v jq &> /dev/null; then
        log_warning "jq 未安装，无法自动配置 allowedOrigins"
        log_info "请手动配置: openclaw config set gateway.controlUi.allowedOrigins '[\"https://YOUR-DOMAIN\"]'"
        return 0
    fi
    
    # 获取 Tailscale 域名
    TAILSCALE_DOMAIN=$(tailscale status --json 2>/dev/null | jq -r '.Self.DNSName' | sed 's/\.$//' || echo "")
    
    # 配置 Gateway allowedOrigins
    if [ -n "$TAILSCALE_DOMAIN" ]; then
        log_info "配置 Gateway 允许的来源..."
        export PATH="$NODE_PATH/installation/bin:$PATH"
        openclaw config set gateway.controlUi.allowedOrigins "[\"https://$TAILSCALE_DOMAIN\"]" 2>/dev/null || {
            log_warning "配置 allowedOrigins 失败"
        }
        
        # 重启 Gateway 应用配置
        log_info "重启 Gateway 应用配置..."
        launchctl unload "$USER_HOME/Library/LaunchAgents/com.openclaw.gateway.plist" 2>/dev/null || true
        launchctl load "$USER_HOME/Library/LaunchAgents/com.openclaw.gateway.plist" || {
            log_warning "重启 Gateway 失败"
        }
        sleep 5
    fi
    
    # 验证配置
    log_info "验证 Tailscale 配置..."
    tailscale serve status || log_warning "无法获取 Tailscale 状态"
    
    log_success "Tailscale 配置完成"
    
    if [ -n "$TAILSCALE_DOMAIN" ]; then
        echo ""
        log_success "访问地址:"
        echo "  https://$TAILSCALE_DOMAIN/openclaw/"
        echo ""
    fi
}


# 生成部署报告
generate_report() {
    log_info "生成部署报告..."
    
    cat > "$SCRIPT_DIR/deployment-report-macos.txt" <<EOF
OpenClaw 部署报告 (macOS)
================

部署时间: $(date)
系统信息: macOS $(sw_vers -productVersion)
Node.js 路径: $NODE_PATH

服务状态:
- OpenClaw Gateway: $(launchctl list | grep com.openclaw.gateway &> /dev/null && echo "运行中" || echo "未运行")
- Nginx: $(brew services list | grep nginx | grep started &> /dev/null && echo "运行中" || echo "未运行")

访问地址:
- Control UI (本地): http://127.0.0.1:18789/openclaw/
- Control UI (Nginx): http://127.0.0.1:9000/openclaw/
- WebSocket: ws://127.0.0.1:9000/openclaw/ws

配置文件:
- OpenClaw: $USER_HOME/.openclaw/openclaw.json
- Nginx: $NGINX_CONF_DIR/openclaw-gateway.conf
- launchd: $USER_HOME/Library/LaunchAgents/com.openclaw.gateway.plist

日志文件:
- OpenClaw: $USER_HOME/Library/Logs/openclaw-gateway.log
- OpenClaw Error: $USER_HOME/Library/Logs/openclaw-gateway-error.log
- Nginx Access: /usr/local/var/log/nginx/openclaw-access.log
- Nginx Error: /usr/local/var/log/nginx/openclaw-error.log

常用命令:
- 查看状态: openclaw status
- 查看日志: tail -f $USER_HOME/Library/Logs/openclaw-gateway.log
- 重启服务: launchctl unload ~/Library/LaunchAgents/com.openclaw.gateway.plist && launchctl load ~/Library/LaunchAgents/com.openclaw.gateway.plist
- 测试连接: openclaw gateway probe
- 重启 Nginx: brew services restart nginx

下一步:
1. 配置 Tailscale (如果未在部署时配置)
   - 在系统偏好设置中启动 Tailscale
   - 重新运行脚本配置路由

2. 配置 Telegram 白名单 (如果启用了 Telegram)
   - 发送消息给 Bot
   - 查看日志获取用户 ID: tail -f $USER_HOME/Library/Logs/openclaw-gateway.log
   - 添加到白名单: openclaw config set channels.telegram.allowFrom '["USER_ID"]'

3. 测试功能
   - 访问 Control UI
   - 测试 Telegram Bot
   - 测试 WebSocket 连接

故障排查:
- Gateway 无法连接: tail -f $USER_HOME/Library/Logs/openclaw-gateway-error.log
- Nginx 502 错误: tail -f /usr/local/var/log/nginx/openclaw-error.log
- API 密钥错误: openclaw models status
- 服务未启动: launchctl list | grep openclaw

macOS 特殊说明:
- 使用 launchd 管理服务（不是 systemd）
- Nginx 配置在 /usr/local/etc/nginx/servers/
- 日志在 ~/Library/Logs/
- 使用 Homebrew 管理软件包

EOF

    if [ $? -eq 0 ]; then
        log_success "部署报告已保存到: $SCRIPT_DIR/deployment-report-macos.txt"
    else
        log_warning "部署报告生成失败"
    fi
}

# 主函数
main() {
    echo ""
    echo "=========================================="
    echo "OpenClaw macOS 部署脚本"
    echo "版本: 2.1.0"
    echo "=========================================="
    echo ""
    
    # 前置检查
    check_macos
    check_network
    
    log_info "开始部署 OpenClaw..."
    echo ""
    
    # 安装步骤
    install_homebrew || {
        log_error "Homebrew 安装失败"
        exit 1
    }
    
    install_dependencies || {
        log_error "依赖安装失败"
        exit 1
    }
    
    create_directories || {
        log_error "目录创建失败"
        exit 1
    }
    
    install_fnm || {
        log_error "fnm 安装失败"
        exit 1
    }
    
    install_nodejs || {
        log_error "Node.js 安装失败"
        exit 1
    }
    
    install_openclaw || {
        log_error "OpenClaw 安装失败"
        exit 1
    }
    
    # 配置步骤
    configure_openclaw || {
        log_error "OpenClaw 配置失败"
        exit 1
    }
    
    configure_nginx || {
        log_error "Nginx 配置失败"
        exit 1
    }
    
    create_launchd_service || {
        log_error "launchd 服务创建失败"
        exit 1
    }
    
    # 启动服务
    start_services || {
        log_error "服务启动失败"
        exit 1
    }
    
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
    echo "配置信息: $SCRIPT_DIR/config.txt"
    echo "部署报告: $SCRIPT_DIR/deployment-report-macos.txt"
    echo ""
    echo "访问 Control UI: http://127.0.0.1:9000/openclaw/"
    echo ""
    echo "macOS 特殊说明:"
    echo "- 服务管理: launchctl (不是 systemd)"
    echo "- 查看日志: tail -f ~/Library/Logs/openclaw-gateway.log"
    echo "- 重启服务: launchctl unload ~/Library/LaunchAgents/com.openclaw.gateway.plist && launchctl load ~/Library/LaunchAgents/com.openclaw.gateway.plist"
    echo ""
    
    # 部署成功，不需要清理
    DEPLOYMENT_FAILED=0
}

# 运行主函数
main "$@"

