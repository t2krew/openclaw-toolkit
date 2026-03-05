# OpenClaw 工具集更新日志

## v1.2.0 (2026-03-06)

### 🎯 重大重构

#### 项目重新定位
- **真正的一键部署** - 从一开始就配置所有正确的设置
- **无需手动修复** - 部署完成后立即可用
- **修复脚本重新定位** - 移至 `tools/` 目录，仅用于维护已有安装

#### 项目结构优化
- **移动修复脚本到 tools/ 目录**
  - `fix-tailscale-routing.sh`
  - `fix-gateway-origin.sh`
  - `reset-gateway-token.sh`
- **添加 tools/README.md** - 说明维护工具的用途
- **更新主 README.md** - 强调一键部署，弱化修复脚本
- **更新 INDEX.txt** - 反映新的项目结构
- **更新 QUICK_REFERENCE.txt** - 突出一键部署流程

#### 部署脚本增强
- **集成 Tailscale 路由配置** - 在部署时自动配置正确的路由
  - 自动重置现有配置
  - 统一配置 80/443 端口代理到 Nginx
  - 自动配置 Gateway allowedOrigins
  - 自动重启 Gateway 应用配置
  - 显示 Tailscale 访问地址

### 📝 设计理念变化

**之前的问题**:
- 先部署有问题的配置
- 然后提供修复脚本
- 这不是"一键部署"，而是"部署+修复"

**现在的解决方案**:
- 部署脚本一次性配置所有正确的设置
- 修复脚本仅用于维护已有安装
- 新用户不需要关心修复脚本

### 💡 用户体验改进

**之前的流程**:
1. 运行部署脚本
2. 发现配置错误
3. 运行 fix-tailscale-routing.sh
4. 运行 fix-gateway-origin.sh
5. 可能还需要运行其他修复脚本

**现在的流程**:
1. 运行 `bash openclaw-deploy.sh`
2. ✅ 完成！立即可用

### 🐛 解决的问题

- 部署脚本配置不完整，需要额外修复步骤
- 修复脚本在主目录，让用户误以为是必需的
- 文档强调修复脚本，而不是一键部署
- 用户体验差，需要多个步骤才能完成部署

---

## v1.1.0 (2026-03-06)

### 🎯 新增功能

#### 快速修复脚本
- **fix-tailscale-routing.sh** - 修复 Tailscale Serve 路由配置
  - 自动重置配置
  - 统一 80/443 端口代理到 Nginx
  - 验证配置正确性
  
- **fix-gateway-origin.sh** - 修复 Gateway Origin 配置
  - 自动获取 Tailscale 域名
  - 添加到 allowedOrigins 白名单
  - 自动重启 Gateway
  
- **reset-gateway-token.sh** - 重置 Gateway Token
  - 生成安全的随机 Token
  - 更新配置并重启服务
  - 保存 Token 到配置文件

#### 文档
- **POST_DEPLOYMENT_ISSUES.md** - 部署后问题与解决方案
  - 详细的问题分析
  - 根本原因说明
  - 完整的解决方案
  - 故障排查流程

### 📝 更新内容

- **README.md** - 添加快速修复脚本章节
- **INDEX.txt** - 更新工具集索引
- **QUICK_REFERENCE.txt** - 添加新问题快速解决方案

### 🐛 解决的问题

1. **Tailscale 路由配置错误**
   - HTTPS 直接暴露 Gateway 端口
   - HTTP 和 HTTPS 配置不一致
   - 绕过 Nginx 统一管理

2. **Gateway Origin 不允许**
   - 通过 Tailscale 访问被拒绝
   - CORS 错误

3. **Gateway 认证失败锁定**
   - Token 认证失败次数过多
   - 需要重置 Token

### 📊 统计数据

- 新增文件: 4 个
- 新增代码: 745 行
- 总文件数: 11 个
- 总代码量: 3,618 行

---

## v1.0.0 (2026-03-06)

### 🎉 初始版本

#### 核心脚本
- **openclaw-deploy.sh** - 一键部署脚本
  - 自动安装依赖
  - 配置 OpenClaw Gateway
  - 配置 Nginx 反向代理
  - 创建 systemd 服务
  
- **openclaw-troubleshoot.sh** - 故障排查工具
  - 自动检测常见问题
  - 提供修复建议
  - 收集诊断信息
  - 快速修复功能

#### 文档
- **README.md** - 完整使用指南
- **DEPLOYMENT_SUMMARY.md** - 部署复盘总结
- **FINAL_REPORT.md** - 项目总结报告
- **QUICK_REFERENCE.txt** - 快速参考卡片
- **INDEX.txt** - 工具集索引

### 🎯 核心功能

- ✅ 一键部署 OpenClaw
- ✅ 自动化故障排查
- ✅ 完整的文档体系
- ✅ 最佳实践总结

### 📊 统计数据

- 总文件数: 7 个
- 总代码量: 2,873 行
- 文档: 1,923 行
- 脚本: 950 行

---

## 版本说明

### 版本号规则
- **主版本号**: 重大架构变更
- **次版本号**: 新增功能或重要更新
- **修订号**: Bug 修复和小改进

### 更新频率
- 根据实际使用中发现的问题持续更新
- 重大问题立即修复
- 功能增强按需添加

---

**维护者:** Claude (Kiro AI Assistant)  
**项目地址:** /root/openclaw-tool/
