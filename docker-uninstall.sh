#!/bin/bash

################################################################################
# OpenClaw Docker 卸载脚本
# 版本: 2.4.0
# 日期: 2026-03-06
#
# 功能:
# - 停止并删除所有 Docker 容器
# - 删除 Docker 镜像
# - 删除 Docker volumes（可选）
# - 清理 Docker 网络
#
# 使用方法:
#   bash docker-uninstall.sh
################################################################################

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

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

# 确认卸载
confirm_uninstall() {
    echo ""
    echo "=========================================="
    echo "OpenClaw Docker 卸载向导"
    echo "=========================================="
    echo ""
    log_warning "此操作将停止并删除所有 OpenClaw Docker 容器"
    echo ""
    read -p "是否继续？(yes/no): " confirm

    if [ "$confirm" != "yes" ]; then
        log_info "已取消卸载"
        exit 0
    fi

    echo ""
}

# 检查 Docker
check_docker() {
    if ! command -v docker &> /dev/null; then
        log_error "Docker 未安装"
        exit 1
    fi

    if ! command -v docker-compose &> /dev/null && ! docker compose version &> /dev/null; then
        log_error "Docker Compose 未安装"
        exit 1
    fi
}

# 停止并删除容器
stop_containers() {
    log_info "停止并删除容器..."

    if [ -f "docker-compose.yml" ]; then
        # 使用 docker-compose 停止
        if command -v docker-compose &> /dev/null; then
            docker-compose down || log_warning "停止容器失败"
        else
            docker compose down || log_warning "停止容器失败"
        fi
        log_success "容器已停止并删除"
    else
        log_warning "未找到 docker-compose.yml，尝试手动删除容器..."

        # 手动删除容器
        docker stop openclaw-gateway 2>/dev/null || true
        docker stop openclaw-nginx 2>/dev/null || true
        docker stop openclaw-tailscale 2>/dev/null || true

        docker rm openclaw-gateway 2>/dev/null || true
        docker rm openclaw-nginx 2>/dev/null || true
        docker rm openclaw-tailscale 2>/dev/null || true

        log_success "容器已删除"
    fi
}

# 删除镜像
remove_images() {
    echo ""
    log_warning "是否删除 Docker 镜像？"
    echo ""
    read -p "删除镜像？(yes/no): " confirm_images

    if [ "$confirm_images" != "yes" ]; then
        log_info "保留 Docker 镜像"
        return 0
    fi

    log_info "删除 Docker 镜像..."

    # 删除自定义镜像
    docker rmi openclaw-toolkit_openclaw-gateway 2>/dev/null || log_warning "删除 openclaw-gateway 镜像失败"
    docker rmi openclaw-toolkit-openclaw-gateway 2>/dev/null || log_warning "删除 openclaw-gateway 镜像失败"

    # 删除基础镜像（可选）
    echo ""
    log_warning "是否删除基础镜像（nginx, node, tailscale）？"
    echo "注意: 这些镜像可能被其他项目使用"
    echo ""
    read -p "删除基础镜像？(yes/no): " confirm_base

    if [ "$confirm_base" = "yes" ]; then
        docker rmi nginx:alpine 2>/dev/null || true
        docker rmi node:24-slim 2>/dev/null || true
        docker rmi tailscale/tailscale:latest 2>/dev/null || true
        log_success "基础镜像已删除"
    fi

    log_success "Docker 镜像已删除"
}

# 删除 volumes
remove_volumes() {
    echo ""
    log_warning "是否删除 Docker volumes（包含所有数据）？"
    echo "  - openclaw-config (配置文件)"
    echo "  - openclaw-data (数据文件)"
    echo "  - nginx-logs (日志文件)"
    echo ""
    log_warning "警告: 删除后数据将无法恢复！"
    echo ""
    read -p "删除 volumes？(yes/no): " confirm_volumes

    if [ "$confirm_volumes" != "yes" ]; then
        log_info "保留 Docker volumes"
        return 0
    fi

    log_info "删除 Docker volumes..."

    if [ -f "docker-compose.yml" ]; then
        # 使用 docker-compose 删除 volumes
        if command -v docker-compose &> /dev/null; then
            docker-compose down -v || log_warning "删除 volumes 失败"
        else
            docker compose down -v || log_warning "删除 volumes 失败"
        fi
    else
        # 手动删除 volumes
        docker volume rm openclaw-config 2>/dev/null || true
        docker volume rm openclaw-data 2>/dev/null || true
        docker volume rm nginx-logs 2>/dev/null || true
        docker volume rm tailscale-state 2>/dev/null || true
    fi

    log_success "Docker volumes 已删除"
}

# 清理网络
cleanup_network() {
    log_info "清理 Docker 网络..."

    docker network rm openclaw-network 2>/dev/null || log_info "网络已不存在"

    log_success "Docker 网络已清理"
}

# 清理未使用的资源
cleanup_unused() {
    echo ""
    log_info "是否清理未使用的 Docker 资源？"
    echo "  - 悬空镜像"
    echo "  - 未使用的容器"
    echo "  - 未使用的网络"
    echo ""
    read -p "清理未使用的资源？(yes/no): " confirm_prune

    if [ "$confirm_prune" != "yes" ]; then
        log_info "跳过清理"
        return 0
    fi

    log_info "清理未使用的资源..."

    docker system prune -f || log_warning "清理失败"

    log_success "未使用的资源已清理"
}

# 生成卸载报告
generate_report() {
    log_info "生成卸载报告..."

    cat > "docker-uninstall-report.txt" <<EOF
OpenClaw Docker 卸载报告
========================

卸载时间: $(date)

已执行的操作:
- ✅ 停止并删除所有容器
- ✅ 删除 Docker 镜像（如果选择）
- ✅ 删除 Docker volumes（如果选择）
- ✅ 清理 Docker 网络
- ✅ 清理未使用的资源（如果选择）

保留的内容:
- Docker 镜像（如果选择保留）
- Docker volumes（如果选择保留）
- docker-compose.yml 配置文件
- .env 环境变量文件

如需重新部署:
  docker-compose up -d

如需完全重新开始:
  1. 确保 .env 文件配置正确
  2. 运行: docker-compose up -d --build

EOF

    log_success "卸载报告已保存到: docker-uninstall-report.txt"
}

# 主函数
main() {
    echo ""
    echo "=========================================="
    echo "OpenClaw Docker 卸载脚本"
    echo "版本: 2.4.0"
    echo "=========================================="
    echo ""

    # 检查 Docker
    check_docker

    # 确认卸载
    confirm_uninstall

    log_info "开始卸载 OpenClaw Docker 部署..."
    echo ""

    # 停止并删除容器
    stop_containers

    # 删除镜像
    remove_images

    # 删除 volumes
    remove_volumes

    # 清理网络
    cleanup_network

    # 清理未使用的资源
    cleanup_unused

    # 生成报告
    generate_report

    echo ""
    echo "=========================================="
    log_success "OpenClaw Docker 卸载完成！"
    echo "=========================================="
    echo ""
    echo "卸载报告: docker-uninstall-report.txt"
    echo ""
    echo "如需重新部署，请运行:"
    echo "  docker-compose up -d"
    echo ""
    echo "如需完全重新构建:"
    echo "  docker-compose up -d --build"
    echo ""
}

# 运行主函数
main "$@"
