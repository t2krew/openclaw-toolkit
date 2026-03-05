#!/bin/bash

################################################################################
# OpenClaw 故障排查工具
# 版本: 1.0.0
# 日期: 2026-03-06
#
# 功能:
# - 自动检测常见问题
# - 提供修复建议
# - 收集诊断信息
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
    echo -e "${GREEN}[✓]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[!]${NC} $1"
}

log_error() {
    echo -e "${RED}[✗]${NC} $1"
}

# 检查 Gateway 状态
check_gateway() {
    echo ""
    echo "=========================================="
    echo "检查 Gateway 状态"
    echo "=========================================="

    export PATH="/root/.local/share/fnm/node-versions/v24.13.0/installation/bin:$PATH"

    # 检查进程
    if pgrep -f "openclaw-gateway" > /dev/null; then
        log_success "Gateway 进程运行中"
    else
        log_error "Gateway 进程未运行"
        echo "修复建议: systemctl start openclaw-gateway.service"
        return 1
    fi

    # 检查端口
    if ss -tlnp | grep -q ":18789"; then
        log_success "Gateway 端口 18789 监听中"
    else
        log_error "Gateway 端口 18789 未监听"
        return 1
    fi

    # 检查连接
    if openclaw gateway probe > /dev/null 2>&1; then
        log_success "Gateway 连接正常"
    else
        log_error "Gateway 连接失败"
        echo "修复建议: 查看日志 journalctl -u openclaw-gateway.service -n 50"
        return 1
    fi

    return 0
}

# 检查 Nginx 状态
check_nginx() {
    echo ""
    echo "=========================================="
    echo "检查 Nginx 状态"
    echo "=========================================="

    # 检查进程
    if systemctl is-active --quiet nginx; then
        log_success "Nginx 服务运行中"
    else
        log_error "Nginx 服务未运行"
        echo "修复建议: systemctl start nginx"
        return 1
    fi

    # 检查配置
    if nginx -t > /dev/null 2>&1; then
        log_success "Nginx 配置正确"
    else
        log_error "Nginx 配置错误"
        echo "修复建议: nginx -t"
        return 1
    fi

    # 检查端口
    if ss -tlnp | grep -q "127.0.0.1:9000"; then
        log_success "Nginx 端口 9000 监听中"
    else
        log_error "Nginx 端口 9000 未监听"
        return 1
    fi

    # 检查响应
    if curl -s http://127.0.0.1:9000/health > /dev/null; then
        log_success "Nginx 响应正常"
    else
        log_error "Nginx 响应失败"
        return 1
    fi

    return 0
}

# 检查 API 密钥配置
check_api_key() {
    echo ""
    echo "=========================================="
    echo "检查 API 密钥配置"
    echo "=========================================="

    export PATH="/root/.local/share/fnm/node-versions/v24.13.0/installation/bin:$PATH"

    # 检查认证状态
    auth_status=$(openclaw models status 2>&1 | grep "anthropic effective=")

    if echo "$auth_status" | grep -q "env:"; then
        log_success "API 密钥配置正确（环境变量）"
        echo "$auth_status"
    elif echo "$auth_status" | grep -q "profile:"; then
        log_warning "API 密钥使用 auth-profiles.json（推荐使用环境变量）"
        echo "$auth_status"
    else
        log_error "API 密钥未配置"
        echo "修复建议: openclaw config set env.ANTHROPIC_API_KEY \"your-key\""
        return 1
    fi

    return 0
}

# 检查 Telegram 配置
check_telegram() {
    echo ""
    echo "=========================================="
    echo "检查 Telegram 配置"
    echo "=========================================="

    export PATH="/root/.local/share/fnm/node-versions/v24.13.0/installation/bin:$PATH"

    # 检查 Telegram 是否启用
    if openclaw config get channels.telegram.enabled 2>&1 | grep -q "true"; then
        log_success "Telegram 已启用"

        # 检查 Bot Token
        if openclaw config get channels.telegram.botToken > /dev/null 2>&1; then
            log_success "Telegram Bot Token 已配置"
        else
            log_error "Telegram Bot Token 未配置"
            return 1
        fi

        # 检查白名单
        allowFrom=$(openclaw config get channels.telegram.allowFrom 2>&1)
        if echo "$allowFrom" | grep -q "Config path not found"; then
            log_warning "Telegram 白名单未配置（所有消息将被拒绝）"
            echo "修复建议: openclaw config set channels.telegram.allowFrom '[\"USER_ID\"]'"
        else
            log_success "Telegram 白名单已配置"
        fi
    else
        log_info "Telegram 未启用"
    fi

    return 0
}

# 检查日志错误
check_logs() {
    echo ""
    echo "=========================================="
    echo "检查最近的错误日志"
    echo "=========================================="

    # 检查 systemd 日志
    errors=$(journalctl -u openclaw-gateway.service -n 50 --no-pager | grep -i "error\|failed" | wc -l)

    if [ "$errors" -gt 0 ]; then
        log_warning "发现 $errors 条错误日志"
        echo "查看详细日志: journalctl -u openclaw-gateway.service -n 50"
    else
        log_success "未发现错误日志"
    fi

    # 检查 OpenClaw 日志
    if [ -f "/tmp/openclaw/openclaw-$(date +%Y-%m-%d).log" ]; then
        log_errors=$(cat "/tmp/openclaw/openclaw-$(date +%Y-%m-%d).log" | grep -i "\"logLevelName\":\"ERROR\"" | wc -l)
        if [ "$log_errors" -gt 0 ]; then
            log_warning "OpenClaw 日志中发现 $log_errors 条错误"
            echo "查看详细日志: cat /tmp/openclaw/openclaw-$(date +%Y-%m-%d).log | grep ERROR"
        else
            log_success "OpenClaw 日志正常"
        fi
    fi

    return 0
}

# 检查磁盘空间
check_disk_space() {
    echo ""
    echo "=========================================="
    echo "检查磁盘空间"
    echo "=========================================="

    disk_usage=$(df -h / | awk 'NR==2 {print $5}' | sed 's/%//')

    if [ "$disk_usage" -lt 80 ]; then
        log_success "磁盘空间充足 (${disk_usage}% 已使用)"
    elif [ "$disk_usage" -lt 90 ]; then
        log_warning "磁盘空间不足 (${disk_usage}% 已使用)"
    else
        log_error "磁盘空间严重不足 (${disk_usage}% 已使用)"
        echo "修复建议: 清理日志文件或扩展磁盘"
    fi

    return 0
}

# 检查内存使用
check_memory() {
    echo ""
    echo "=========================================="
    echo "检查内存使用"
    echo "=========================================="

    mem_usage=$(free | awk 'NR==2 {printf "%.0f", $3/$2 * 100}')

    if [ "$mem_usage" -lt 80 ]; then
        log_success "内存使用正常 (${mem_usage}%)"
    elif [ "$mem_usage" -lt 90 ]; then
        log_warning "内存使用较高 (${mem_usage}%)"
    else
        log_error "内存使用过高 (${mem_usage}%)"
        echo "修复建议: 重启服务或增加内存"
    fi

    return 0
}

# 收集诊断信息
collect_diagnostics() {
    echo ""
    echo "=========================================="
    echo "收集诊断信息"
    echo "=========================================="

    export PATH="/root/.local/share/fnm/node-versions/v24.13.0/installation/bin:$PATH"

    diag_file="/root/openclaw-tool/diagnostics-$(date +%Y%m%d-%H%M%S).txt"

    cat > "$diag_file" <<EOF
OpenClaw 诊断信息
================
生成时间: $(date)

系统信息:
$(uname -a)

OpenClaw 版本:
$(openclaw --version 2>&1)

OpenClaw 状态:
$(openclaw status 2>&1)

Gateway 探测:
$(openclaw gateway probe 2>&1)

模型状态:
$(openclaw models status 2>&1)

进程信息:
$(ps aux | grep openclaw)

端口监听:
$(ss -tlnp | grep -E "18789|9000")

Nginx 状态:
$(systemctl status nginx --no-pager)

OpenClaw Gateway 状态:
$(systemctl status openclaw-gateway.service --no-pager)

最近的错误日志:
$(journalctl -u openclaw-gateway.service -n 50 --no-pager | grep -i "error\|failed")

磁盘空间:
$(df -h)

内存使用:
$(free -h)

配置文件:
$(cat /root/.openclaw/openclaw.json 2>&1 | sed 's/"apiKey": ".*"/"apiKey": "***"/g' | sed 's/"token": ".*"/"token": "***"/g' | sed 's/"botToken": ".*"/"botToken": "***"/g')

EOF

    log_success "诊断信息已保存到: $diag_file"
}

# 快速修复
quick_fix() {
    echo ""
    echo "=========================================="
    echo "快速修复"
    echo "=========================================="

    export PATH="/root/.local/share/fnm/node-versions/v24.13.0/installation/bin:$PATH"

    log_info "重启 OpenClaw Gateway..."
    systemctl restart openclaw-gateway.service
    sleep 5

    log_info "重载 Nginx..."
    systemctl reload nginx

    log_info "检查服务状态..."
    if systemctl is-active --quiet openclaw-gateway.service; then
        log_success "OpenClaw Gateway 运行正常"
    else
        log_error "OpenClaw Gateway 启动失败"
    fi

    if systemctl is-active --quiet nginx; then
        log_success "Nginx 运行正常"
    else
        log_error "Nginx 启动失败"
    fi
}

# 主菜单
show_menu() {
    echo ""
    echo "=========================================="
    echo "OpenClaw 故障排查工具"
    echo "=========================================="
    echo ""
    echo "1. 完整检查"
    echo "2. 检查 Gateway"
    echo "3. 检查 Nginx"
    echo "4. 检查 API 密钥"
    echo "5. 检查 Telegram"
    echo "6. 检查日志"
    echo "7. 收集诊断信息"
    echo "8. 快速修复（重启服务）"
    echo "9. 退出"
    echo ""
    read -p "请选择操作 [1-9]: " choice

    case $choice in
        1)
            check_gateway
            check_nginx
            check_api_key
            check_telegram
            check_logs
            check_disk_space
            check_memory
            ;;
        2)
            check_gateway
            ;;
        3)
            check_nginx
            ;;
        4)
            check_api_key
            ;;
        5)
            check_telegram
            ;;
        6)
            check_logs
            ;;
        7)
            collect_diagnostics
            ;;
        8)
            quick_fix
            ;;
        9)
            exit 0
            ;;
        *)
            log_error "无效选择"
            ;;
    esac

    # 继续显示菜单
    show_menu
}

# 主函数
main() {
    if [ "$1" = "--auto" ]; then
        # 自动模式：执行完整检查
        check_gateway
        check_nginx
        check_api_key
        check_telegram
        check_logs
        check_disk_space
        check_memory
    else
        # 交互模式：显示菜单
        show_menu
    fi
}

main "$@"
