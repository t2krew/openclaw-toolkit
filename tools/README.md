# 维护工具 (Maintenance Tools)

这些工具用于维护和修复已有的 OpenClaw 安装，**不是新部署所必需的**。

## 🎯 重要说明

如果你是**新用户**，只需要运行：

```bash
bash openclaw-deploy.sh
```

部署脚本会自动配置所有正确的设置，**不需要运行这些修复工具**。

---

## 🔧 工具列表

### fix-tailscale-routing.sh

**用途**: 修复已有安装中错误的 Tailscale 路由配置

**使用场景**:
- 你在部署脚本之前手动配置了 Tailscale
- Tailscale 路由配置不正确
- 需要重新配置 Tailscale 路由

**使用方法**:
```bash
bash tools/fix-tailscale-routing.sh
```

---

### fix-gateway-origin.sh

**用途**: 修复 Gateway allowedOrigins 配置

**使用场景**:
- 通过 Tailscale 访问时出现 "origin not allowed" 错误
- 需要添加新的域名到白名单
- 需要重新配置 allowedOrigins

**使用方法**:
```bash
bash tools/fix-gateway-origin.sh
```

---

### reset-gateway-token.sh

**用途**: 重置 Gateway 认证 Token

**使用场景**:
- Token 泄露需要更换
- 认证失败被锁定
- 忘记了 Token

**使用方法**:
```bash
bash tools/reset-gateway-token.sh
```

---

## 💡 设计理念

这些工具的存在是为了：

1. **维护已有安装** - 修复手动配置或旧版本部署的问题
2. **重新配置** - 当需要更改配置时使用
3. **故障恢复** - 当配置损坏时快速恢复

**新用户不需要关心这些工具**，部署脚本已经包含了所有正确的配置。

---

## 📚 相关文档

- 完整部署指南: [../README.md](../README.md)
- 故障排查: [../POST_DEPLOYMENT_ISSUES.md](../POST_DEPLOYMENT_ISSUES.md)
- 部署复盘: [../DEPLOYMENT_SUMMARY.md](../DEPLOYMENT_SUMMARY.md)
