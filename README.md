# OpenClaw Deployment Toolkit

[English](#english) | [中文](#中文)

---

## English

**One-click deployment toolkit for OpenClaw Gateway** - Automated installation, configuration, and management.

### 🎯 Features

- **True One-Click Deployment** - All configurations done correctly from the start
- **No Manual Fixes Required** - Deploy once, use immediately
- **Intelligent Troubleshooting** - Automatic problem detection and diagnosis
- **Complete Documentation** - From quick start to in-depth analysis
- **Best Practices Built-in** - Based on real-world deployment experience

### 🚀 Quick Start

```bash
# Clone the repository
git clone https://github.com/t2krew/openclaw-toolkit.git
cd openclaw-toolkit

# One-click deployment - that's it!
bash openclaw-deploy.sh
```

**That's all you need!** The deployment script will:
- ✅ Install all dependencies
- ✅ Configure OpenClaw Gateway
- ✅ Set up Nginx reverse proxy with correct WebSocket paths
- ✅ Configure Tailscale routing (if selected)
- ✅ Set up Gateway allowedOrigins automatically
- ✅ Create systemd service for auto-start
- ✅ Verify everything works

### 📦 What's Included

#### Core Scripts
- **openclaw-deploy.sh** - One-click deployment script (all you need!)
- **openclaw-troubleshoot.sh** - Diagnostic and troubleshooting tool

#### Maintenance Tools (Optional)
Located in `tools/` directory - only needed for existing installations or manual fixes:
- `fix-tailscale-routing.sh` - Fix Tailscale routing (for old installations)
- `fix-gateway-origin.sh` - Fix Gateway origin (for manual configurations)
- `reset-gateway-token.sh` - Reset authentication token (if needed)

**New users don't need these tools** - the deployment script handles everything correctly.

#### Documentation
- `README.md` - This file
- `DEPLOYMENT_SUMMARY.md` - Architecture and best practices
- `POST_DEPLOYMENT_ISSUES.md` - Historical issues and solutions
- `FINAL_REPORT.md` - Complete project summary
- `CHANGELOG.md` - Version history
- `QUICK_REFERENCE.txt` - Quick reference card
- `INDEX.txt` - Toolkit index

### 🌐 Architecture

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

### 📚 Documentation

- **Quick Start**: Just run `bash openclaw-deploy.sh`
- **Troubleshooting**: Run `bash openclaw-troubleshoot.sh` if you encounter issues
- **Architecture Details**: See [DEPLOYMENT_SUMMARY.md](DEPLOYMENT_SUMMARY.md)
- **Maintenance Tools**: See [tools/README.md](tools/README.md) (for existing installations)

### 🎓 Built-in Best Practices

The deployment script automatically implements:
- ✅ **WebSocket Reverse Proxy** - Unified path prefix design
- ✅ **API Key Management** - Environment variable approach
- ✅ **Tailscale Configuration** - All traffic through Nginx with correct routing
- ✅ **Gateway Security** - Token authentication and origin whitelist
- ✅ **Service Management** - Systemd integration for reliability

### 📊 Statistics

- **Total Files**: 15+
- **One Command**: `bash openclaw-deploy.sh`
- **Zero Manual Fixes**: Everything configured correctly from the start

### 📞 Support

- **Official Docs**: https://docs.openclaw.ai/
- **Troubleshooting**: https://docs.openclaw.ai/troubleshooting
- **Issues**: https://github.com/t2krew/openclaw-toolkit/issues

### 📝 License

MIT License

### 🙏 Acknowledgments

Developed during the deployment of OpenClaw Gateway on Raspberry Pi (ARM64).

---

## 中文

**OpenClaw Gateway 一键部署工具** - 自动化安装、配置和管理。

### 🎯 特性

- **真正的一键部署** - 从一开始就正确配置所有设置
- **无需手动修复** - 部署一次，立即使用
- **智能故障排查** - 自动检测和诊断问题
- **完整文档** - 从快速开始到深度分析
- **内置最佳实践** - 基于实际部署经验

### 🚀 快速开始

```bash
# 克隆仓库
git clone https://github.com/t2krew/openclaw-toolkit.git
cd openclaw-toolkit

# 一键部署 - 就这么简单！
bash openclaw-deploy.sh
```

**这就是全部！** 部署脚本会：
- ✅ 安装所有依赖
- ✅ 配置 OpenClaw Gateway
- ✅ 设置 Nginx 反向代理和正确的 WebSocket 路径
- ✅ 配置 Tailscale 路由（如果选择）
- ✅ 自动设置 Gateway allowedOrigins
- ✅ 创建 systemd 服务实现自动启动
- ✅ 验证所有功能正常

### 📦 包含内容

#### 核心脚本
- **openclaw-deploy.sh** - 一键部署脚本（你只需要这个！）
- **openclaw-troubleshoot.sh** - 诊断和故障排查工具

#### 维护工具（可选）
位于 `tools/` 目录 - 仅用于已有安装或手动修复：
- `fix-tailscale-routing.sh` - 修复 Tailscale 路由（用于旧安装）
- `fix-gateway-origin.sh` - 修复 Gateway Origin（用于手动配置）
- `reset-gateway-token.sh` - 重置认证 Token（如果需要）

**新用户不需要这些工具** - 部署脚本已正确处理所有配置。

#### 文档
- `README.md` - 本文件
- `DEPLOYMENT_SUMMARY.md` - 架构和最佳实践
- `POST_DEPLOYMENT_ISSUES.md` - 历史问题和解决方案
- `FINAL_REPORT.md` - 完整项目总结
- `CHANGELOG.md` - 更新日志
- `QUICK_REFERENCE.txt` - 快速参考卡片
- `INDEX.txt` - 工具集索引

### 🌐 架构

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

### 📚 文档

- **快速开始**: 只需运行 `bash openclaw-deploy.sh`
- **故障排查**: 遇到问题运行 `bash openclaw-troubleshoot.sh`
- **架构细节**: 查看 [DEPLOYMENT_SUMMARY.md](DEPLOYMENT_SUMMARY.md)
- **维护工具**: 查看 [tools/README.md](tools/README.md)（用于已有安装）

### 🎓 内置最佳实践

部署脚本自动实现：
- ✅ **WebSocket 反向代理** - 统一路径前缀设计
- ✅ **API 密钥管理** - 环境变量方式
- ✅ **Tailscale 配置** - 所有流量通过 Nginx，路由配置正确
- ✅ **Gateway 安全** - Token 认证和来源白名单
- ✅ **服务管理** - Systemd 集成确保可靠性

### 📊 统计数据

- **总文件数**: 15+
- **一条命令**: `bash openclaw-deploy.sh`
- **零手动修复**: 从一开始就正确配置所有设置

### 📞 获取帮助

- **官方文档**: https://docs.openclaw.ai/
- **故障排查**: https://docs.openclaw.ai/troubleshooting
- **问题反馈**: https://github.com/t2krew/openclaw-toolkit/issues

### 📝 许可证

MIT License

### 🙏 致谢

在 Raspberry Pi (ARM64) 上部署 OpenClaw Gateway 过程中开发。

---

**Version**: v1.2.0
**Last Updated**: 2026-03-06
**Repository**: https://github.com/t2krew/openclaw-toolkit
