# OpenClaw Deployment Toolkit

[English](#english) | [中文](#中文)

---

## English

A comprehensive toolkit for deploying and managing OpenClaw Gateway, including automated deployment scripts, troubleshooting tools, and quick fix utilities.

### 🎯 Features

- **One-Click Deployment** - Automated installation and configuration
- **Intelligent Troubleshooting** - Automatic problem detection and diagnosis
- **Quick Fix Scripts** - One-command solutions for common issues
- **Complete Documentation** - From quick reference to in-depth analysis
- **Best Practices** - Based on real-world deployment experience

### 📦 What's Included

#### Core Scripts (5)
- `openclaw-deploy.sh` - One-click deployment script
- `openclaw-troubleshoot.sh` - Troubleshooting tool
- `fix-tailscale-routing.sh` - Fix Tailscale routing configuration
- `fix-gateway-origin.sh` - Fix Gateway origin configuration
- `reset-gateway-token.sh` - Reset Gateway authentication token

#### Documentation (7)
- `README.md` - Complete usage guide
- `DEPLOYMENT_SUMMARY.md` - Deployment review and analysis
- `POST_DEPLOYMENT_ISSUES.md` - Post-deployment issues and solutions
- `FINAL_REPORT.md` - Project summary report
- `CHANGELOG.md` - Version history
- `QUICK_REFERENCE.txt` - Quick reference card
- `INDEX.txt` - Toolkit index

### 🚀 Quick Start

```bash
# Clone the repository
git clone https://github.com/YOUR_USERNAME/openclaw-toolkit.git
cd openclaw-toolkit

# View the toolkit index
cat INDEX.txt

# View quick reference
cat QUICK_REFERENCE.txt

# One-click deployment
bash openclaw-deploy.sh

# Troubleshooting
bash openclaw-troubleshoot.sh
```

### 🔧 Quick Fixes

```bash
# Fix Tailscale routing
bash fix-tailscale-routing.sh

# Fix Gateway origin configuration
bash fix-gateway-origin.sh

# Reset Gateway token
bash reset-gateway-token.sh
```

### 📚 Documentation

- **Quick Reference**: `QUICK_REFERENCE.txt` - Most commonly used commands
- **Usage Guide**: `README.md` - Complete instructions and FAQ
- **Deployment Review**: `DEPLOYMENT_SUMMARY.md` - Architecture and best practices
- **Issue Solutions**: `POST_DEPLOYMENT_ISSUES.md` - Common problems and fixes
- **Project Report**: `FINAL_REPORT.md` - Complete project summary

### 🐛 Solved Problems

1. ✅ WebSocket path configuration issues
2. ✅ Anthropic API key authentication failures
3. ✅ Tailscale routing configuration errors
4. ✅ Gateway origin not allowed errors
5. ✅ Gateway authentication lockout

### 🎓 Best Practices

- **WebSocket Reverse Proxy** - Unified path prefix design
- **API Key Management** - Environment variable approach
- **Tailscale Configuration** - All traffic through Nginx
- **Gateway Security** - Token authentication and origin whitelist

### 📊 Statistics

- **Total Files**: 12
- **Total Lines**: 3,741
- **Scripts**: 1,198 lines
- **Documentation**: 2,543 lines

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

### 📞 Support

- **Official Docs**: https://docs.openclaw.ai/
- **Troubleshooting**: https://docs.openclaw.ai/troubleshooting
- **Telegram**: https://docs.openclaw.ai/zh-CN/channels/telegram
- **Gateway**: https://docs.openclaw.ai/zh-CN/gateway

### 📝 License

MIT License

### 🙏 Acknowledgments

Developed during the deployment of OpenClaw Gateway on Raspberry Pi (ARM64).

---

## 中文

OpenClaw Gateway 部署和管理的完整工具集，包括自动化部署脚本、故障排查工具和快速修复工具。

### 🎯 特性

- **一键部署** - 自动化安装和配置
- **智能故障排查** - 自动检测和诊断问题
- **快速修复脚本** - 常见问题的一键解决方案
- **完整文档** - 从快速参考到深度分析
- **最佳实践** - 基于实际部署经验

### 📦 包含内容

#### 核心脚本 (5 个)
- `openclaw-deploy.sh` - 一键部署脚本
- `openclaw-troubleshoot.sh` - 故障排查工具
- `fix-tailscale-routing.sh` - 修复 Tailscale 路由配置
- `fix-gateway-origin.sh` - 修复 Gateway Origin 配置
- `reset-gateway-token.sh` - 重置 Gateway Token

#### 文档 (7 个)
- `README.md` - 完整使用指南
- `DEPLOYMENT_SUMMARY.md` - 部署复盘总结
- `POST_DEPLOYMENT_ISSUES.md` - 部署后问题与解决方案
- `FINAL_REPORT.md` - 项目总结报告
- `CHANGELOG.md` - 更新日志
- `QUICK_REFERENCE.txt` - 快速参考卡片
- `INDEX.txt` - 工具集索引

### 🚀 快速开始

```bash
# 克隆仓库
git clone https://github.com/YOUR_USERNAME/openclaw-toolkit.git
cd openclaw-toolkit

# 查看工具集索引
cat INDEX.txt

# 查看快速参考
cat QUICK_REFERENCE.txt

# 一键部署
bash openclaw-deploy.sh

# 故障排查
bash openclaw-troubleshoot.sh
```

### 🔧 快速修复

```bash
# 修复 Tailscale 路由
bash fix-tailscale-routing.sh

# 修复 Gateway Origin 配置
bash fix-gateway-origin.sh

# 重置 Gateway Token
bash reset-gateway-token.sh
```

### 📚 文档

- **快速参考**: `QUICK_REFERENCE.txt` - 最常用的命令
- **使用指南**: `README.md` - 完整说明和常见问题
- **部署复盘**: `DEPLOYMENT_SUMMARY.md` - 架构和最佳实践
- **问题解决**: `POST_DEPLOYMENT_ISSUES.md` - 常见问题和修复方案
- **项目报告**: `FINAL_REPORT.md` - 完整项目总结

### 🐛 解决的问题

1. ✅ WebSocket 路径配置混乱
2. ✅ Anthropic API 密钥认证失败
3. ✅ Tailscale 路由配置错误
4. ✅ Gateway Origin 不允许错误
5. ✅ Gateway 认证失败锁定

### 🎓 最佳实践

- **WebSocket 反向代理** - 统一路径前缀设计
- **API 密钥管理** - 环境变量方式
- **Tailscale 配置** - 所有流量通过 Nginx
- **Gateway 安全** - Token 认证和来源白名单

### 📊 统计数据

- **总文件数**: 12 个
- **总代码量**: 3,741 行
- **脚本**: 1,198 行
- **文档**: 2,543 行

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

### 📞 获取帮助

- **官方文档**: https://docs.openclaw.ai/
- **故障排查**: https://docs.openclaw.ai/troubleshooting
- **Telegram**: https://docs.openclaw.ai/zh-CN/channels/telegram
- **Gateway**: https://docs.openclaw.ai/zh-CN/gateway

### 📝 许可证

MIT License

### 🙏 致谢

在 Raspberry Pi (ARM64) 上部署 OpenClaw Gateway 过程中开发。

---

**Version**: v1.1.0
**Last Updated**: 2026-03-06
**Maintainer**: Claude (Kiro AI Assistant)
