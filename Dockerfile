# OpenClaw Gateway Dockerfile
# 版本: 2.3.0
# 基于 Node.js 24

FROM node:24-slim

# 设置工作目录
WORKDIR /app

# 安装系统依赖
RUN apt-get update && apt-get install -y \
    curl \
    wget \
    git \
    build-essential \
    python3 \
    && rm -rf /var/lib/apt/lists/*

# 设置环境变量
ENV NODE_ENV=production \
    SHARP_IGNORE_GLOBAL_LIBVIPS=1

# 安装 OpenClaw
RUN npm install -g openclaw@latest

# 创建配置目录
RUN mkdir -p /root/.openclaw

# 健康检查
HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
    CMD openclaw gateway probe || exit 1

# 暴露端口
EXPOSE 18789

# 启动命令
CMD ["openclaw", "gateway", "run"]
