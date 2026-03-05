# Docker 部署指南

本指南将帮助你使用 Docker Compose 部署 OpenClaw Gateway。

## 为什么使用 Docker？

- ✅ **跨平台** - 在 Linux、macOS、Windows 上运行相同的容器
- ✅ **隔离环境** - 不影响主机系统
- ✅ **易于管理** - 一键启动、停止、更新
- ✅ **无需依赖** - 不需要安装 Node.js、Nginx 等
- ✅ **可移植性** - 轻松迁移到其他服务器

## 前置要求

- Docker 20.10+
- Docker Compose 2.0+

### 安装 Docker

**Linux:**
```bash
curl -fsSL https://get.docker.com | sh
sudo usermod -aG docker $USER
```

**macOS:**
下载并安装 [Docker Desktop for Mac](https://www.docker.com/products/docker-desktop)

**Windows:**
下载并安装 [Docker Desktop for Windows](https://www.docker.com/products/docker-desktop)

## 快速开始

### 1. 克隆仓库

```bash
git clone https://github.com/t2krew/openclaw-toolkit.git
cd openclaw-toolkit
```

### 2. 配置环境变量

```bash
# 复制环境变量示例文件
cp .env.example .env

# 编辑 .env 文件
nano .env  # 或使用其他编辑器
```

**必需配置：**

```bash
# Anthropic API 密钥
ANTHROPIC_API_KEY=sk-ant-xxxxx

# Gateway Token（生成方法见下文）
GATEWAY_TOKEN=your_generated_token_here
```

**生成 Gateway Token：**

```bash
# Linux/macOS
openssl rand -hex 24

# Windows (PowerShell)
-join ((48..57) + (97..102) | Get-Random -Count 48 | % {[char]$_})
```

### 3. 启动服务

```bash
# 启动所有服务
docker-compose up -d

# 查看日志
docker-compose logs -f

# 查看特定服务日志
docker-compose logs -f openclaw-gateway
```

### 4. 访问服务

- **Control UI**: http://localhost:9000/openclaw/
- **WebSocket**: ws://localhost:9000/openclaw/ws

## 架构说明

```
┌─────────────────────────────────────────┐
│         Docker Compose                  │
├─────────────────────────────────────────┤
│                                         │
│  ┌──────────────┐   ┌──────────────┐  │
│  │    Nginx     │   │   OpenClaw   │  │
│  │  (Port 9000) │──▶│   Gateway    │  │
│  │              │   │  (Port 18789)│  │
│  └──────────────┘   └──────────────┘  │
│         │                   │          │
│         │                   │          │
│  ┌──────▼───────────────────▼──────┐  │
│  │      openclaw-network           │  │
│  └─────────────────────────────────┘  │
│                                         │
└─────────────────────────────────────────┘
```

**服务说明：**

1. **openclaw-gateway**
   - OpenClaw Gateway 主服务
   - 端口：18789（内部）
   - 数据持久化：配置和数据存储在 Docker volumes

2. **nginx**
   - 反向代理服务
   - 端口：9000（对外）
   - 处理 WebSocket 和 HTTP 请求

3. **tailscale**（可选）
   - Tailscale 网络服务
   - 需要取消注释并配置

## 常用命令

### 服务管理

```bash
# 启动服务
docker-compose up -d

# 停止服务
docker-compose down

# 重启服务
docker-compose restart

# 重启特定服务
docker-compose restart openclaw-gateway

# 停止并删除所有数据（危险！）
docker-compose down -v
```

### 日志查看

```bash
# 查看所有日志
docker-compose logs

# 实时查看日志
docker-compose logs -f

# 查看特定服务日志
docker-compose logs openclaw-gateway
docker-compose logs nginx

# 查看最近 100 行日志
docker-compose logs --tail=100
```

### 服务状态

```bash
# 查看运行状态
docker-compose ps

# 查看详细信息
docker-compose ps -a

# 进入容器
docker-compose exec openclaw-gateway bash

# 在容器中执行命令
docker-compose exec openclaw-gateway openclaw status
```

### 更新服务

```bash
# 拉取最新代码
git pull

# 重新构建镜像
docker-compose build

# 重启服务
docker-compose up -d

# 或者一步完成
docker-compose up -d --build
```

## 配置说明

### 环境变量

所有配置通过 `.env` 文件管理：

```bash
# Anthropic API 配置
ANTHROPIC_API_KEY=sk-ant-xxxxx
ANTHROPIC_BASE_URL=https://api.anthropic.com

# Gateway 配置
GATEWAY_TOKEN=your_token_here

# Telegram 配置（可选）
TELEGRAM_ENABLED=false
TELEGRAM_BOT_TOKEN=

# Tailscale 配置（可选）
# TAILSCALE_AUTH_KEY=tskey-auth-xxxxx
```

### 端口配置

修改 `docker-compose.yml` 中的端口映射：

```yaml
services:
  nginx:
    ports:
      - "9000:9000"  # 改为其他端口，如 "8080:9000"
```

### 数据持久化

数据存储在 Docker volumes 中：

```bash
# 查看 volumes
docker volume ls | grep openclaw

# 备份数据
docker run --rm -v openclaw-config:/data -v $(pwd):/backup alpine tar czf /backup/openclaw-backup.tar.gz /data

# 恢复数据
docker run --rm -v openclaw-config:/data -v $(pwd):/backup alpine tar xzf /backup/openclaw-backup.tar.gz -C /
```

## Telegram 配置

### 1. 启用 Telegram

编辑 `.env` 文件：

```bash
TELEGRAM_ENABLED=true
TELEGRAM_BOT_TOKEN=your_bot_token_here
```

### 2. 重启服务

```bash
docker-compose restart openclaw-gateway
```

### 3. 配置白名单

```bash
# 进入容器
docker-compose exec openclaw-gateway bash

# 查看日志获取用户 ID
openclaw logs | grep telegram

# 添加到白名单
openclaw config set channels.telegram.allowFrom '["USER_ID"]'

# 退出容器
exit

# 重启服务
docker-compose restart openclaw-gateway
```

## Tailscale 配置

### 1. 获取 Auth Key

访问 https://login.tailscale.com/admin/settings/keys 生成 Auth Key。

### 2. 配置环境变量

编辑 `.env` 文件：

```bash
TAILSCALE_AUTH_KEY=tskey-auth-xxxxx
```

### 3. 启用 Tailscale 服务

编辑 `docker-compose.yml`，取消注释 `tailscale` 服务部分。

### 4. 启动服务

```bash
docker-compose up -d
```

### 5. 配置路由

```bash
# 进入 Tailscale 容器
docker-compose exec tailscale sh

# 配置 serve
tailscale serve --bg http://nginx:9000

# 退出容器
exit
```

## 故障排查

### 服务无法启动

```bash
# 查看详细日志
docker-compose logs

# 检查配置
docker-compose config

# 检查端口占用
netstat -tlnp | grep 9000  # Linux
lsof -i :9000              # macOS
```

### Gateway 无法连接

```bash
# 检查 Gateway 状态
docker-compose exec openclaw-gateway openclaw gateway probe

# 查看 Gateway 日志
docker-compose logs openclaw-gateway

# 检查环境变量
docker-compose exec openclaw-gateway env | grep OPENCLAW
```

### Nginx 502 错误

```bash
# 检查 Gateway 是否运行
docker-compose ps openclaw-gateway

# 检查网络连接
docker-compose exec nginx ping openclaw-gateway

# 查看 Nginx 日志
docker-compose logs nginx
```

### 数据丢失

```bash
# 检查 volumes
docker volume ls | grep openclaw

# 检查 volume 挂载
docker-compose exec openclaw-gateway ls -la /root/.openclaw
```

## 性能优化

### 限制资源使用

编辑 `docker-compose.yml`：

```yaml
services:
  openclaw-gateway:
    deploy:
      resources:
        limits:
          cpus: '2'
          memory: 2G
        reservations:
          cpus: '1'
          memory: 1G
```

### 日志轮转

已在 `docker-compose.yml` 中配置：

```yaml
logging:
  driver: "json-file"
  options:
    max-size: "10m"
    max-file: "3"
```

## 生产环境建议

### 1. 使用 HTTPS

配置反向代理（如 Caddy、Traefik）：

```yaml
services:
  caddy:
    image: caddy:alpine
    ports:
      - "443:443"
    volumes:
      - ./Caddyfile:/etc/caddy/Caddyfile
      - caddy-data:/data
```

### 2. 备份策略

```bash
# 创建备份脚本
cat > backup.sh <<'EOF'
#!/bin/bash
DATE=$(date +%Y%m%d_%H%M%S)
docker run --rm \
  -v openclaw-config:/data \
  -v $(pwd)/backups:/backup \
  alpine tar czf /backup/openclaw-$DATE.tar.gz /data
EOF

chmod +x backup.sh

# 添加到 crontab（每天备份）
crontab -e
# 添加: 0 2 * * * /path/to/backup.sh
```

### 3. 监控

```bash
# 查看资源使用
docker stats

# 查看容器健康状态
docker-compose ps
```

### 4. 自动更新

```bash
# 创建更新脚本
cat > update.sh <<'EOF'
#!/bin/bash
cd /path/to/openclaw-toolkit
git pull
docker-compose pull
docker-compose up -d --build
docker image prune -f
EOF

chmod +x update.sh
```

## 卸载

### 停止并删除服务

```bash
# 停止服务
docker-compose down

# 删除所有数据（危险！）
docker-compose down -v

# 删除镜像
docker rmi openclaw-toolkit_openclaw-gateway
```

## 常见问题

### Q: Docker 和原生部署有什么区别？

A:
- Docker: 容器化，隔离环境，易于管理
- 原生: 直接安装在系统上，性能略好

### Q: 可以在 Docker 中使用 GPU 吗？

A: 可以，需要安装 nvidia-docker 并配置 GPU 支持。

### Q: 数据存储在哪里？

A: 存储在 Docker volumes 中，位置：
- Linux: `/var/lib/docker/volumes/`
- macOS: Docker Desktop VM 内部
- Windows: Docker Desktop VM 内部

### Q: 如何迁移到其他服务器？

A:
1. 备份 volumes
2. 复制 `.env` 和配置文件
3. 在新服务器上恢复

### Q: 性能如何？

A: Docker 性能接近原生，CPU 开销 < 5%。

## 更多资源

- **Docker 文档**: https://docs.docker.com/
- **Docker Compose 文档**: https://docs.docker.com/compose/
- **OpenClaw 文档**: https://docs.openclaw.ai/
- **本项目 GitHub**: https://github.com/t2krew/openclaw-toolkit

## 支持

如有问题，请在 GitHub 提交 Issue：
https://github.com/t2krew/openclaw-toolkit/issues

---

**版本**: v2.4.0
**更新时间**: 2026-03-06
**适用于**: Docker 20.10+ / Docker Compose 2.0+
