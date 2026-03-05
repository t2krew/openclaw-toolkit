# OpenClaw 部署工具集

[English](README.md) | **[中文](README_CN.md)**

---

**Linux 服务器生产环境部署工具** - 自动化安装、配置和管理，包括 Nginx、Tailscale 和 systemd。

> **注意**: 本工具专为 **Linux 服务器生产环境部署**设计。如需在 macOS/Windows 开发环境安装，请使用[官方安装器](https://docs.openclaw.ai/zh-CN/install)。

## 🎯 特性

- **真正的一键部署** - 从一开始就正确配置所有设置
- **无需手动修复** - 部署一次，立即使用
- **跨平台支持** - 支持 Debian、Ubuntu、CentOS、RHEL、Arch Linux
- **完整的依赖管理** - 自动安装所有需要的依赖
- **智能故障排查** - 自动检测和诊断问题
- **内置最佳实践** - 基于实际部署经验

## 🚀 快速开始

### Docker（推荐所有平台）🐳

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
# 克隆仓库
git clone https://github.com/t2krew/openclaw-toolkit.git
cd openclaw-toolkit

# 一键部署
sudo bash openclaw-deploy.sh
```

**macOS:**
```bash
# 克隆仓库
git clone https://github.com/t2krew/openclaw-toolkit.git
cd openclaw-toolkit

# 一键部署
bash openclaw-deploy-macos.sh
```

## 💻 系统要求

### 支持的 Linux 发行版

本工具支持以下 Linux 发行版：

- ✅ **Debian** 10+
- ✅ **Ubuntu** 20.04+
- ✅ **CentOS** 7+
- ✅ **RHEL** 8+
- ✅ **Arch Linux**
- ✅ **Manjaro**

### macOS 支持

**新功能！** 我们现在提供完整的 macOS 部署脚本，具备完整的生产环境功能：

```bash
# macOS 部署（包括 Nginx、Tailscale、launchd）
bash openclaw-deploy-macos.sh
```

**macOS 功能特性:**
- ✅ 完整的生产环境部署（与 Linux 相同）
- ✅ Nginx 反向代理配置
- ✅ Tailscale 网络设置
- ✅ launchd 服务管理（代替 systemd）
- ✅ Homebrew 包管理
- ✅ 所有安全配置

**macOS 要求:**
- macOS 10.15 (Catalina) 或更高版本
- 管理员权限
- 网络连接

### Windows 用户

**对于 Windows**，我们推荐使用 WSL2（Windows Linux 子系统）：

**快速设置：**

1. 下载并运行设置脚本：
   ```powershell
   # 在 PowerShell（管理员）中
   iwr -useb https://raw.githubusercontent.com/t2krew/openclaw-toolkit/main/install-wsl2.ps1 | iex
   ```

2. 或手动安装 WSL2：
   ```powershell
   # 在 PowerShell（管理员）中
   wsl --install
   ```

3. 重启后，在 Ubuntu (WSL2) 中：
   ```bash
   git clone https://github.com/t2krew/openclaw-toolkit.git
   cd openclaw-toolkit
   sudo bash openclaw-deploy.sh
   ```

**为什么选择 WSL2？**
- ✅ Windows 上的完整 Linux 环境
- ✅ 原生性能
- ✅ 完整的 systemd 支持
- ✅ 使用相同的 Linux 部署脚本
- ✅ 无需虚拟机

**从 Windows 访问：**
- Control UI: http://localhost:9000/openclaw/
- WebSocket: ws://localhost:9000/openclaw/ws

详细说明请参考 [WINDOWS_WSL2_GUIDE.md](WINDOWS_WSL2_GUIDE.md)。

**替代方案：** 如果只需要开发环境（不需要 Nginx/Tailscale），可使用官方安装器：
```powershell
iwr -useb https://openclaw.ai/install.ps1 | iex
```

更多信息请参考[官方安装指南](https://docs.openclaw.ai/zh-CN/install)。

## 📦 本工具的功能

## 📦 本工具的功能

**这就是全部！** 部署脚本会：
- ✅ 检查网络连接
- ✅ 安装所有依赖（包括 jq、nginx 等）
- ✅ 通过 fnm 安装 Node.js
- ✅ 安装 OpenClaw Gateway
- ✅ 使用你的 API 密钥配置 OpenClaw
- ✅ 设置 Nginx 反向代理和正确的 WebSocket 路径
- ✅ 配置 Tailscale 路由（如果选择）
- ✅ 自动设置 Gateway allowedOrigins
- ✅ 创建 systemd 服务实现自动启动
- ✅ 验证所有功能正常

**这是完整的生产环境部署**，不仅仅是安装器。包括：
- Nginx 反向代理配置
- Tailscale 网络设置
- systemd 服务管理
- 安全配置（Token 认证、来源白名单）

## 📁 包含内容

### 部署脚本
- **docker-compose.yml** - Docker Compose 配置（推荐）
- **Dockerfile** - OpenClaw Gateway Docker 镜像
- **openclaw-deploy.sh** - Linux 原生部署脚本
- **openclaw-deploy-macos.sh** - macOS 原生部署脚本
- **install-wsl2.ps1** - Windows WSL2 设置助手（PowerShell）

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

```
Internet
   ↓
Tailscale Network (HTTPS)
   ↓
Nginx (127.0.0.1:9000)
   ├── /openclaw/         → OpenClaw Control UI
   ├── /openclaw/ws       → OpenClaw WebSocket
   └── /                  → Tailscale Web UI
```

## 🎓 内置最佳实践

部署脚本自动实现：
- ✅ **动态路径解析** - 无硬编码路径，支持任何 Node.js 版本
- ✅ **跨平台 Nginx** - 支持 Debian/Ubuntu 和 CentOS/RHEL 的目录结构
- ✅ **完整的错误处理** - 每一步都检查，失败时清理
- ✅ **WebSocket 反向代理** - 统一路径前缀设计
- ✅ **API 密钥管理** - 环境变量方式
- ✅ **Tailscale 配置** - 所有流量通过 Nginx，路由配置正确
- ✅ **Gateway 安全** - Token 认证和来源白名单
- ✅ **服务管理** - Systemd 集成确保可靠性

## 🔧 故障排查

如果遇到问题：

```bash
# 运行故障排查工具
bash openclaw-troubleshoot.sh

# 检查服务状态
systemctl status openclaw-gateway.service

# 查看日志
journalctl -u openclaw-gateway.service -f
```

## 📞 获取帮助

- **官方文档**: https://docs.openclaw.ai/
- **故障排查**: https://docs.openclaw.ai/troubleshooting
- **问题反馈**: https://github.com/t2krew/openclaw-toolkit/issues

## 📝 许可证

MIT License

## 🙏 致谢

在 Raspberry Pi (ARM64) 上部署 OpenClaw Gateway 过程中开发。

---

**版本**: v2.0.0
**更新时间**: 2026-03-06
**仓库地址**: https://github.com/t2krew/openclaw-toolkit
