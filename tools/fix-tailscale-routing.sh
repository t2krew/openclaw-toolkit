#!/bin/bash

################################################################################
# Tailscale 路由配置修复脚本
# 版本: 1.0.0
# 日期: 2026-03-06
#
# 功能: 修复 Tailscale Serve 路由配置，确保所有流量通过 Nginx
################################################################################

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

echo ""
echo "=========================================="
echo "修复 Tailscale Serve 路由配置"
echo "=========================================="
echo ""

# 检查 Tailscale 是否运行
if ! command -v tailscale &> /dev/null; then
    log_error "Tailscale 未安装"
    exit 1
fi

if ! tailscale status &> /dev/null; then
    log_error "Tailscale 未运行，请先启动: tailscale up"
    exit 1
fi

log_info "当前配置:"
tailscale serve status
echo ""

# 重置配置
log_info "重置 Tailscale Serve 配置..."
tailscale serve reset

# 配置 HTTPS (443)
log_info "配置 HTTPS (443) → Nginx (9000)..."
tailscale serve --bg http://127.0.0.1:9000

# 配置 HTTP (80)
log_info "配置 HTTP (80) → Nginx (9000)..."
tailscale serve --http=80 --bg http://127.0.0.1:9000

# 验证配置
echo ""
log_info "新配置:"
tailscale serve status

echo ""
log_info "详细配置:"
tailscale serve status --json | jq '.'

echo ""
log_success "✅ Tailscale 路由配置已修复"
echo ""
echo "访问地址:"
TAILSCALE_DOMAIN=$(tailscale status --json | jq -r '.Self.DNSName' | sed 's/\.$//')
echo "  https://$TAILSCALE_DOMAIN/openclaw/"
echo ""
