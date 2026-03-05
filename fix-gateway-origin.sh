#!/bin/bash

################################################################################
# Gateway Origin 配置修复脚本
# 版本: 1.0.0
# 日期: 2026-03-06
#
# 功能: 添加 Tailscale 域名到 Gateway 允许的来源列表
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
echo "修复 Gateway Origin 配置"
echo "=========================================="
echo ""

# 设置 PATH
export PATH="/root/.local/share/fnm/node-versions/v24.13.0/installation/bin:$PATH"

# 检查 OpenClaw 是否安装
if ! command -v openclaw &> /dev/null; then
    log_error "OpenClaw 未安装"
    exit 1
fi

# 获取 Tailscale 域名
log_info "获取 Tailscale 域名..."
TAILSCALE_DOMAIN=$(tailscale status --json 2>/dev/null | jq -r '.Self.DNSName' | sed 's/\.$//')

if [ -z "$TAILSCALE_DOMAIN" ]; then
    log_error "无法获取 Tailscale 域名，请确保 Tailscale 正在运行"
    exit 1
fi

log_success "Tailscale 域名: https://$TAILSCALE_DOMAIN"

# 添加到允许列表
log_info "添加到 Gateway 允许列表..."
openclaw config set gateway.controlUi.allowedOrigins "[\"https://$TAILSCALE_DOMAIN\"]"

# 重启 Gateway
log_info "重启 Gateway..."
pkill -f "openclaw-gateway" 2>/dev/null || true
sleep 2

log_info "启动 Gateway..."
nohup openclaw gateway run > /tmp/gateway-origin-fix.log 2>&1 &

# 等待启动
log_info "等待 Gateway 启动..."
for i in {1..15}; do
    sleep 1
    if openclaw gateway probe &> /dev/null; then
        break
    fi
    echo -n "."
done
echo ""

# 验证
if openclaw gateway probe &> /dev/null; then
    log_success "Gateway 启动成功"
else
    log_error "Gateway 启动失败，请查看日志: tail -f /tmp/gateway-origin-fix.log"
    exit 1
fi

# 显示配置
echo ""
log_info "当前允许的来源:"
openclaw config get gateway.controlUi.allowedOrigins

echo ""
log_success "✅ Gateway Origin 配置已修复"
echo ""
echo "访问地址:"
echo "  https://$TAILSCALE_DOMAIN/openclaw/"
echo ""
