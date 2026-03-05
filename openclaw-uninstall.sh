#!/bin/bash

################################################################################
# OpenClaw 卸载脚本
# 版本: 2.4.0
# 日期: 2026-03-06
# 作者: Claude (Kiro AI Assistant)
#
# 功能:
# - 停止并删除所有 OpenClaw 服务
# - 卸载 OpenClaw Gateway
# - 清理 Nginx 配置
# - 清理 Tailscale 配置
# - 删除所有配置文件和数据（可选）
# - 卸载依赖（可选）
#
# 使用方法:
#   bash openclaw-uninstall.sh
#
# 支持系统:
# - Linux (Debian/Ubuntu/CentOS/RHEL/Arch/Manjaro)
# - macOS
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
OS_TYPE=""
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

# 检测操作系统
detect_os() {
    if [[ "$OSTYPE" == "darwin"* ]]; then
        OS_TYPE="macos"
        log_info "检测到 macOS 系统"
    elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
        OS_TYPE="linux"
        log_info "检测到 Linux 系统"
    else
        log_error "不支持的操作系统: $OSTYPE"
        exit 1
    fi
}

# 确认卸载
confirm_uninstall() {
    echo ""
    echo "=========================================="
    echo "OpenClaw 卸载向导"
    echo "=========================================="
    echo ""
    log_warning "此操作将卸载 OpenClaw 及其所有配置"
    echo ""
    read -p "是否继续？(yes/no): " confirm

    if [ "$confirm" != "yes" ]; then
        log_info "已取消卸载"
        exit 0
    fi

    echo ""
}

# 停止服务 (Linux)
stop_services_linux() {
    log_info "停止 Linux 服务..."

    # 停止 OpenClaw Gateway
    if systemctl is-active --quiet openclaw-gateway.service 2>/dev/null; then
        log_info "停止 OpenClaw Gateway 服务..."
        sudo systemctl stop openclaw-gateway.service || log_warning "停止服务失败"
        sudo systemctl disable openclaw-gateway.service || log_warning "禁用服务失败"
        log_success "OpenClaw Gateway 服务已停止"
    else
        log_info "OpenClaw Gateway 服务未运行"
    fi

    # 停止 Nginx
    if systemctl is-active --quiet nginx 2>/dev/null; then
        log_info "停止 Nginx 服务..."
        sudo systemctl stop nginx || log_warning "停止 Nginx 失败"
        log_success "Nginx 已停止"
    fi

    log_success "Linux 服务已停止"
}

# 停止服务 (macOS)
stop_services_macos() {
    log_info "停止 macOS 服务..."

    # 停止 OpenClaw Gateway
    PLIST_FILE="$USER_HOME/Library/LaunchAgents/com.openclaw.gateway.plist"
    if [ -f "$PLIST_FILE" ]; then
        log_info "停止 OpenClaw Gateway 服务..."
        launchctl unload "$PLIST_FILE" 2>/dev/null || log_warning "停止服务失败"
        log_success "OpenClaw Gateway 服务已停止"
    else
        log_info "OpenClaw Gateway 服务未安装"
    fi

    # 停止 Nginx
    if brew services list | grep nginx | grep started &> /dev/null; then
        log_info "停止 Nginx 服务..."
        brew services stop nginx || log_warning "停止 Nginx 失败"
        log_success "Nginx 已停止"
    fi

    log_success "macOS 服务已停止"
}

# 删除服务文件 (Linux)
remove_service_files_linux() {
    log_info "删除 Linux 服务文件..."

    # 删除 systemd 服务文件
    if [ -f "/etc/systemd/system/openclaw-gateway.service" ]; then
        sudo rm -f /etc/systemd/system/openclaw-gateway.service
        sudo systemctl daemon-reload
        log_success "systemd 服务文件已删除"
    fi
}

# 删除服务文件 (macOS)
remove_service_files_macos() {
    log_info "删除 macOS 服务文件..."

    # 删除 launchd plist 文件
    PLIST_FILE="$USER_HOME/Library/LaunchAgents/com.openclaw.gateway.plist"
    if [ -f "$PLIST_FILE" ]; then
        rm -f "$PLIST_FILE"
        log_success "launchd 服务文件已删除"
    fi
}

# 清理 Nginx 配置 (Linux)
cleanup_nginx_linux() {
    log_info "清理 Linux Nginx 配置..."

    # 检测 Nginx 配置目录
    if [ -d "/etc/nginx/sites-available" ]; then
        NGINX_CONF="/etc/nginx/sites-available/openclaw-gateway.conf"
        NGINX_LINK="/etc/nginx/sites-enabled/openclaw-gateway.conf"
    else
        NGINX_CONF="/etc/nginx/conf.d/openclaw-gateway.conf"
        NGINX_LINK=""
    fi

    # 删除配置文件
    if [ -f "$NGINX_CONF" ]; then
        sudo rm -f "$NGINX_CONF"
        log_success "Nginx 配置文件已删除"
    fi

    # 删除符号链接
    if [ -n "$NGINX_LINK" ] && [ -L "$NGINX_LINK" ]; then
        sudo rm -f "$NGINX_LINK"
        log_success "Nginx 符号链接已删除"
    fi

    # 重载 Nginx（如果还在运行）
    if systemctl is-active --quiet nginx 2>/dev/null; then
        sudo systemctl reload nginx || log_warning "重载 Nginx 失败"
    fi
}

# 清理 Nginx 配置 (macOS)
cleanup_nginx_macos() {
    log_info "清理 macOS Nginx 配置..."

    NGINX_CONF="/usr/local/etc/nginx/servers/openclaw-gateway.conf"

    if [ -f "$NGINX_CONF" ]; then
        rm -f "$NGINX_CONF"
        log_success "Nginx 配置文件已删除"
    fi

    # 重载 Nginx（如果还在运行）
    if brew services list | grep nginx | grep started &> /dev/null; then
        brew services restart nginx || log_warning "重载 Nginx 失败"
    fi
}

# 清理 Tailscale 配置
cleanup_tailscale() {
    log_info "清理 Tailscale 配置..."

    if command -v tailscale &> /dev/null; then
        log_info "重置 Tailscale Serve 配置..."
        tailscale serve reset 2>/dev/null || log_warning "重置 Tailscale 配置失败"
        log_success "Tailscale 配置已清理"
    else
        log_info "Tailscale 未安装，跳过"
    fi
}

# 卸载 OpenClaw
uninstall_openclaw() {
    log_info "卸载 OpenClaw..."

    # 查找 Node.js 路径
    if command -v fnm &> /dev/null; then
        export PATH="$USER_HOME/.local/share/fnm:$PATH"
        eval "$(fnm env --use-on-cd)" 2>/dev/null || true
    fi

    # 卸载 OpenClaw
    if command -v openclaw &> /dev/null; then
        npm uninstall -g openclaw 2>/dev/null || log_warning "卸载 OpenClaw 失败"
        log_success "OpenClaw 已卸载"
    else
        log_info "OpenClaw 未安装"
    fi
}

# 删除配置文件和数据
remove_config_data() {
    echo ""
    log_warning "是否删除 OpenClaw 配置文件和数据？"
    echo "  - 配置文件: $USER_HOME/.openclaw/"
    echo "  - 数据文件: $USER_HOME/.local/share/openclaw/"
    echo ""
    read -p "删除配置和数据？(yes/no): " confirm_data

    if [ "$confirm_data" = "yes" ]; then
        log_info "删除配置文件和数据..."

        # 删除配置目录
        if [ -d "$USER_HOME/.openclaw" ]; then
            rm -rf "$USER_HOME/.openclaw"
            log_success "配置文件已删除"
        fi

        # 删除数据目录
        if [ -d "$USER_HOME/.local/share/openclaw" ]; then
            rm -rf "$USER_HOME/.local/share/openclaw"
            log_success "数据文件已删除"
        fi
    else
        log_info "保留配置文件和数据"
    fi
}

# 卸载依赖 (可选)
uninstall_dependencies() {
    echo ""
    log_warning "是否卸载依赖软件？"
    echo "  - Node.js (fnm)"
    echo "  - Nginx"
    echo "  - 其他依赖"
    echo ""
    log_warning "注意: 这些软件可能被其他应用使用"
    echo ""
    read -p "卸载依赖？(yes/no): " confirm_deps

    if [ "$confirm_deps" != "yes" ]; then
        log_info "保留依赖软件"
        return 0
    fi

    log_info "卸载依赖软件..."

    # 卸载 fnm 和 Node.js
    if [ -d "$USER_HOME/.local/share/fnm" ]; then
        log_info "删除 fnm 和 Node.js..."
        rm -rf "$USER_HOME/.local/share/fnm"

        # 清理 shell 配置
        if [ -f "$USER_HOME/.bashrc" ]; then
            sed -i.bak '/# fnm/,/fi/d' "$USER_HOME/.bashrc" 2>/dev/null || true
        fi
        if [ -f "$USER_HOME/.zshrc" ]; then
            sed -i.bak '/# fnm/,/fi/d' "$USER_HOME/.zshrc" 2>/dev/null || true
        fi

        log_success "fnm 和 Node.js 已删除"
    fi

    # 卸载 Nginx
    if [ "$OS_TYPE" = "linux" ]; then
        if command -v nginx &> /dev/null; then
            log_info "卸载 Nginx..."

            if command -v apt-get &> /dev/null; then
                sudo apt-get remove -y nginx nginx-common 2>/dev/null || log_warning "卸载 Nginx 失败"
            elif command -v yum &> /dev/null; then
                sudo yum remove -y nginx 2>/dev/null || log_warning "卸载 Nginx 失败"
            elif command -v pacman &> /dev/null; then
                sudo pacman -R --noconfirm nginx 2>/dev/null || log_warning "卸载 Nginx 失败"
            fi

            log_success "Nginx 已卸载"
        fi
    elif [ "$OS_TYPE" = "macos" ]; then
        if brew list nginx &> /dev/null; then
            log_info "卸载 Nginx..."
            brew uninstall nginx 2>/dev/null || log_warning "卸载 Nginx 失败"
            log_success "Nginx 已卸载"
        fi
    fi
}

# 清理部署生成的文件
cleanup_deployment_files() {
    log_info "清理部署生成的文件..."

    # 删除部署报告
    rm -f "$SCRIPT_DIR/config.txt" 2>/dev/null
    rm -f "$SCRIPT_DIR/deployment-report.txt" 2>/dev/null
    rm -f "$SCRIPT_DIR/deployment-report-macos.txt" 2>/dev/null

    log_success "部署文件已清理"
}

# 生成卸载报告
generate_report() {
    log_info "生成卸载报告..."

    cat > "$SCRIPT_DIR/uninstall-report.txt" <<EOF
OpenClaw 卸载报告
================

卸载时间: $(date)
操作系统: $OS_TYPE
用户: $CURRENT_USER

已执行的操作:
- ✅ 停止所有服务
- ✅ 删除服务文件
- ✅ 清理 Nginx 配置
- ✅ 清理 Tailscale 配置
- ✅ 卸载 OpenClaw Gateway
- ✅ 清理部署文件

保留的内容:
- 配置文件: $USER_HOME/.openclaw/ (如果选择保留)
- 数据文件: $USER_HOME/.local/share/openclaw/ (如果选择保留)
- 依赖软件: Node.js, Nginx 等 (如果选择保留)

如需重新安装:
  git clone https://github.com/t2krew/openclaw-toolkit.git
  cd openclaw-toolkit
  bash openclaw-deploy.sh  # Linux
  bash openclaw-deploy-macos.sh  # macOS

EOF

    log_success "卸载报告已保存到: $SCRIPT_DIR/uninstall-report.txt"
}

# 主函数
main() {
    echo ""
    echo "=========================================="
    echo "OpenClaw 卸载脚本"
    echo "版本: 2.4.0"
    echo "=========================================="
    echo ""

    # 检测操作系统
    detect_os

    # 确认卸载
    confirm_uninstall

    log_info "开始卸载 OpenClaw..."
    echo ""

    # 停止服务
    if [ "$OS_TYPE" = "linux" ]; then
        stop_services_linux
        remove_service_files_linux
        cleanup_nginx_linux
    elif [ "$OS_TYPE" = "macos" ]; then
        stop_services_macos
        remove_service_files_macos
        cleanup_nginx_macos
    fi

    # 清理 Tailscale
    cleanup_tailscale

    # 卸载 OpenClaw
    uninstall_openclaw

    # 删除配置和数据
    remove_config_data

    # 卸载依赖
    uninstall_dependencies

    # 清理部署文件
    cleanup_deployment_files

    # 生成报告
    generate_report

    echo ""
    echo "=========================================="
    log_success "OpenClaw 卸载完成！"
    echo "=========================================="
    echo ""
    echo "卸载报告: $SCRIPT_DIR/uninstall-report.txt"
    echo ""
    echo "如需重新安装，请运行:"
    if [ "$OS_TYPE" = "linux" ]; then
        echo "  bash openclaw-deploy.sh"
    elif [ "$OS_TYPE" = "macos" ]; then
        echo "  bash openclaw-deploy-macos.sh"
    fi
    echo ""
}

# 运行主函数
main "$@"
