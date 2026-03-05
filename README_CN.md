# OpenClaw 部署工具集

[English](README.md) | **[中文](README_CN.md)**

---

**OpenClaw Gateway 生产环境部署工具** - 自动化安装、配置和管理，包括 Nginx、Tailscale 和服务管理。

## 🎯 特性

- **Docker 支持** - 所有平台最简单的部署方式
- **跨平台** - Linux、macOS、Windows (WSL2)
- **完全自动化** - 一条命令部署所有内容
- **生产就绪** - 包含 Nginx、Tailscale、服务管理
- **最佳实践** - 基于实际部署经验

## 🚀 快速开始

### Docker（推荐）🐳

**最简单的部署方式，适用于所有平台：**

```bash
# 克隆仓库
git clone https://github.com/t2krew/openclaw-toolkit.git
cd openclaw-toolkit

# 配置环境变量
cp .env.example .env
# 编辑 .env 文件，添加你的 API 密钥

# 启动所有服务
docker-compose up -d

# 访问 Control UI
# http://localhost:9000/openclaw/
```

**为什么选择 Docker？**
- ✅ 支持 Linux、macOS、Windows
- ✅ 无需安装 Node.js、Nginx 等依赖
- ✅ 隔离环境
- ✅ 易于管理和更新
- ✅ 一条命令启动所有服务

详细说明请参考 [DOCKER_GUIDE.md](DOCKER_GUIDE.md)。

### 原生安装

**Linux:**
```bash
git clone https://github.com/t2krew/openclaw-toolkit.git
cd openclaw-toolkit
sudo bash openclaw-deploy.sh
```

**macOS:**
```bash
git clone https://github.com/t2krew/openclaw-toolkit.git
cd openclaw-toolkit
bash openclaw-deploy-macos.sh
```

**Windows (WSL2):**
```powershell
# 在 PowerShell（管理员）中
wsl --install
# 重启后，在 Ubuntu 中：
git clone https://github.com/t2krew/openclaw-toolkit.git
cd openclaw-toolkit
sudo bash openclaw-deploy.sh
```

详细的 Windows 说明请参考 [WINDOWS_WSL2_GUIDE.md](WINDOWS_WSL2_GUIDE.md)。

## 💻 系统要求

### Docker 部署（推荐）
- Docker 20.10+
- Docker Compose 2.0+
- 支持平台：Linux、macOS、Windows

### 原生部署

**Linux:**
- Debian 10+ / Ubuntu 20.04+
- CentOS 7+ / RHEL 8+
- Arch Linux / Manjaro

**macOS:**
- macOS 10.15 (Catalina) 或更高版本
- Intel 或 Apple Silicon (M1/M2/M3)

**Windows:**
- Windows 10 版本 2004+ 或 Windows 11
- WSL2 + Ubuntu/Debian

## 📦 本工具的功能

**完整的生产环境部署：**
- ✅ 安装 OpenClaw Gateway
- ✅ 配置 Nginx 反向代理
- ✅ 设置 Tailscale 网络（可选）
- ✅ 配置服务管理（systemd/launchd）
- ✅ 设置安全配置（Token 认证、来源白名单）
- ✅ 启用开机自动启动

## 📁 包含内容

### 部署脚本
- **docker-compose.yml** - Docker Compose 配置（推荐）
- **Dockerfile** - OpenClaw Gateway Docker 镜像
- **openclaw-deploy.sh** - Linux 原生部署脚本
- **openclaw-deploy-macos.sh** - macOS 原生部署脚本
- **install-wsl2.ps1** - Windows WSL2 设置助手（PowerShell）

### 卸载脚本
- **docker-uninstall.sh** - Docker 卸载脚本
- **openclaw-uninstall.sh** - 原生卸载脚本（Linux/macOS）
- **windows-uninstall.ps1** - Windows WSL2 卸载脚本（PowerShell）

### 配置文件
- **nginx.conf** - Nginx 反向代理配置
- **.env.example** - 环境变量模板

### 工具与文档
- **openclaw-troubleshoot.sh** - 诊断和故障排查工具
- **README.md** - 英文文档
- **README_CN.md** - 中文文档
- **DOCKER_GUIDE.md** - Docker 部署指南
- **WINDOWS_WSL2_GUIDE.md** - Windows WSL2 详细指南
- **CHANGELOG.md** - 更新日志
- **LICENSE** - MIT 许可证

## 🌐 架构

**Docker 部署：**
```
Docker Compose
├── openclaw-gateway (容器)
├── nginx (容器)
└── tailscale (可选)
```

**原生部署：**
```
Internet
   ↓
Tailscale Network (HTTPS)
   ↓
Nginx (127.0.0.1:9000)
   ├── /openclaw/         → OpenClaw Control UI
   └── /openclaw/ws       → OpenClaw WebSocket
```

## 🔧 故障排查

**Docker:**
```bash
# 查看日志
docker-compose logs -f

# 重启服务
docker-compose restart

# 检查状态
docker-compose ps
```

**原生部署:**
```bash
# 运行故障排查工具
bash openclaw-troubleshoot.sh

# 检查服务状态（Linux）
systemctl status openclaw-gateway.service

# 检查服务状态（macOS）
launchctl list | grep openclaw
```

## 🗑️ 卸载

**Docker:**
```bash
# 运行 Docker 卸载脚本
bash docker-uninstall.sh

# 或手动卸载
docker-compose down -v  # 删除容器和数据卷
```

**原生部署（Linux/macOS）:**
```bash
# 运行卸载脚本
bash openclaw-uninstall.sh

# 脚本会执行：
# - 停止所有服务
# - 删除服务文件
# - 清理 Nginx 配置
# - 卸载 OpenClaw Gateway
# - 可选删除配置/数据
# - 可选卸载依赖软件
```

**Windows (WSL2):**
```powershell
# 在 PowerShell 中
.\windows-uninstall.ps1

# 脚本会执行：
# - 在 WSL2 Ubuntu 中卸载 OpenClaw
# - 可选删除配置/数据
# - 可选卸载 WSL2 和 Ubuntu
```

## 📞 获取帮助

- **GitHub Issues**: https://github.com/t2krew/openclaw-toolkit/issues
- **官方文档**: https://docs.openclaw.ai/

## ☕ 请喝咖啡

如果这个项目对你有帮助，可以请我喝杯咖啡！您的支持是我最大的动力！🙏

<div align="center">
  <table>
    <tr>
      <td align="center">
        <img src="images/wechat-pay.jpg" width="200" alt="微信支付"><br>
        <b>微信支付</b>
      </td>
      <td align="center">
        <img src="images/alipay.jpg" width="200" alt="支付宝"><br>
        <b>支付宝</b>
      </td>
    </tr>
  </table>
</div>

## 📝 许可证

MIT License

---

**版本**: v2.5.0
**更新时间**: 2026-03-06
**仓库地址**: https://github.com/t2krew/openclaw-toolkit
