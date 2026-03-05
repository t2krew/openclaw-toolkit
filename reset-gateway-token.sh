#!/bin/bash

################################################################################
# Gateway Token 重置脚本
# 版本: 1.0.0
# 日期: 2026-03-06
#
# 功能: 重置 Gateway Token，解决认证失败问题
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

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

echo ""
echo "=========================================="
echo "重置 Gateway Token"
echo "=========================================="
echo ""

# 设置 PATH
export PATH="/root/.local/share/fnm/node-versions/v24.13.0/installation/bin:$PATH"

# 检查 OpenClaw 是否安装
if ! command -v openclaw &> /dev/null; then
    log_error "OpenClaw 未安装"
    exit 1
fi

# 生成新 Token
log_info "生成新 Token..."
NEW_TOKEN=$(openssl rand -hex 24)

log_success "新 Token: $NEW_TOKEN"

# 更新配置
log_info "更新配置..."
openclaw config set gateway.auth.token "$NEW_TOKEN"

# 重启 Gateway
log_info "重启 Gateway..."
pkill -f "openclaw-gateway" 2>/dev/null || true
sleep 2

log_info "启动 Gateway..."
nohup openclaw gateway run > /tmp/gateway-token-reset.log 2>&1 &

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
    log_error "Gateway 启动失败，请查看日志: tail -f /tmp/gateway-token-reset.log"
    exit 1
fi

# 获取 Tailscale 域名
TAILSCALE_DOMAIN=$(tailscale status --json 2>/dev/null | jq -r '.Self.DNSName' | sed 's/\.$//' || echo "")

# 保存配置
log_info "保存配置到文件..."
cat >> /root/openclaw-tool/config.txt <<EOF

=== Token 更新 $(date) ===
Gateway Token: $NEW_TOKEN
EOF

echo ""
log_success "✅ Gateway Token 已重置"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "新 Token: $NEW_TOKEN"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

if [ -n "$TAILSCALE_DOMAIN" ]; then
    echo "访问地址:"
    echo "  https://$TAILSCALE_DOMAIN/openclaw/?token=$NEW_TOKEN"
    echo ""
fi

log_warning "请妥善保管此 Token，它已保存到 /root/openclaw-tool/config.txt"
echo ""
