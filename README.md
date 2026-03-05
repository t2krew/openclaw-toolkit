# OpenClaw 工具集使用指南

## 📁 目录结构

```
/root/openclaw-tool/
├── README.md                      # 本文件
├── DEPLOYMENT_SUMMARY.md          # 部署复盘总结
├── POST_DEPLOYMENT_ISSUES.md      # 部署后问题与解决方案
├── QUICK_REFERENCE.txt            # 快速参考卡片
├── INDEX.txt                      # 工具集索引
├── FINAL_REPORT.md                # 项目总结报告
├── openclaw-deploy.sh             # 一键部署脚本
├── openclaw-troubleshoot.sh       # 故障排查工具
├── fix-tailscale-routing.sh       # 修复 Tailscale 路由
├── fix-gateway-origin.sh          # 修复 Gateway Origin
├── reset-gateway-token.sh         # 重置 Gateway Token
├── config.txt                     # 配置信息（部署后生成）
└── deployment-report.txt          # 部署报告（部署后生成）
```

---

## 🚀 快速开始

### 1. 一键部署 OpenClaw

```bash
cd /root/openclaw-tool
bash openclaw-deploy.sh
```

**功能：**
- ✅ 自动安装所有依赖（fnm、Node.js、Nginx）
- ✅ 安装并配置 OpenClaw Gateway
- ✅ 配置 Nginx 反向代理
- ✅ 配置 Telegram Bot（可选）
- ✅ 创建 systemd 服务
- ✅ 自动启动并验证服务
- ✅ 生成配置和部署报告

**使用场景：**
- 全新安装 OpenClaw
- 快速部署到新服务器
- 标准化部署流程

---

### 2. 故障排查工具

```bash
cd /root/openclaw-tool
bash openclaw-troubleshoot.sh
```

**功能：**
- ✅ 检查 Gateway 状态
- ✅ 检查 Nginx 状态
- ✅ 检查 API 密钥配置
- ✅ 检查 Telegram 配置
- ✅ 检查错误日志
- ✅ 检查系统资源（磁盘、内存）
- ✅ 收集诊断信息
- ✅ 快速修复（重启服务）

**使用场景：**
- 服务异常时快速诊断
- 定期健康检查
- 收集问题报告

**自动模式：**
```bash
bash openclaw-troubleshoot.sh --auto
```

---

## 📚 详细文档

### 部署复盘总结

查看完整的部署过程分析和经验总结：

```bash
cat /root/openclaw-tool/DEPLOYMENT_SUMMARY.md
```

**内容包括：**
- 部署架构图
- 遇到的问题及解决方案
- 关键配置说明
- 最佳实践总结
- 后续优化方向

---

## 🔧 常用命令

### OpenClaw 管理

```bash
# 查看状态
openclaw status

# 查看日志
openclaw logs --follow

# 测试连接
openclaw gateway probe

# 查看模型状态
openclaw models status

# 配置管理
openclaw config get <path>
openclaw config set <path> <value>
```

### 服务管理

```bash
# 启动服务
systemctl start openclaw-gateway.service

# 停止服务
systemctl stop openclaw-gateway.service

# 重启服务
systemctl restart openclaw-gateway.service

# 查看状态
systemctl status openclaw-gateway.service

# 查看日志
journalctl -u openclaw-gateway.service -f
```

### Nginx 管理

```bash
# 测试配置
nginx -t

# 重载配置
systemctl reload nginx

# 重启 Nginx
systemctl restart nginx

# 查看日志
tail -f /var/log/nginx/openclaw-access.log
tail -f /var/log/nginx/openclaw-error.log
```

---

## 🔧 快速修复脚本

### 1. 修复 Tailscale 路由配置

```bash
bash /root/openclaw-tool/fix-tailscale-routing.sh
```

**功能：**
- ✅ 重置 Tailscale Serve 配置
- ✅ 配置 80 和 443 端口统一代理到 Nginx
- ✅ 验证配置正确性

**使用场景：**
- Tailscale 路由配置错误
- HTTPS 直接暴露 Gateway 端口
- 需要统一路由配置

---

### 2. 修复 Gateway Origin 配置

```bash
bash /root/openclaw-tool/fix-gateway-origin.sh
```

**功能：**
- ✅ 自动获取 Tailscale 域名
- ✅ 添加到 Gateway 允许列表
- ✅ 重启 Gateway 应用配置

**使用场景：**
- 出现 "origin not allowed" 错误
- 通过 Tailscale 访问被拒绝
- CORS 错误

---

### 3. 重置 Gateway Token

```bash
bash /root/openclaw-tool/reset-gateway-token.sh
```

**功能：**
- ✅ 生成新的安全 Token
- ✅ 更新 Gateway 配置
- ✅ 重启 Gateway
- ✅ 保存 Token 到配置文件

**使用场景：**
- 认证失败被锁定
- Token 泄露需要更换
- 忘记 Token

---

## 🎯 常见问题解决

### 问题 1：Tailscale 路由配置错误

**症状：**
```
https://raspberrypi.tailcc9b33.ts.net
|-- / proxy http://127.0.0.1:18789  ← 错误！
```

**解决方案：**
```bash
bash /root/openclaw-tool/fix-tailscale-routing.sh
```

**详细说明：** 参见 `POST_DEPLOYMENT_ISSUES.md`

---

### 问题 2：Origin 不允许错误

**症状：**
```
origin not allowed (open the Control UI from the gateway host or allow it in gateway.controlUi.allowedOrigins)
```

**解决方案：**
```bash
bash /root/openclaw-tool/fix-gateway-origin.sh
```

**详细说明：** 参见 `POST_DEPLOYMENT_ISSUES.md`

---

### 问题 3：认证失败锁定

**症状：**
```
unauthorized: too many failed authentication attempts (retry later)
```

**解决方案：**
```bash
bash /root/openclaw-tool/reset-gateway-token.sh
```

**详细说明：** 参见 `POST_DEPLOYMENT_ISSUES.md`

---

### 问题 4：Gateway 无法连接

**症状：**
```
Gateway Status: unreachable
```

**解决方案：**
```bash
# 1. 检查服务状态
systemctl status openclaw-gateway.service

# 2. 查看日志
journalctl -u openclaw-gateway.service -n 50

# 3. 重启服务
systemctl restart openclaw-gateway.service

# 4. 验证连接
openclaw gateway probe
```

---

### 问题 5：API 密钥错误

**症状：**
```
No API key found for provider "anthropic"
```

**解决方案：**
```bash
# 1. 检查认证状态
openclaw models status

# 2. 配置环境变量（推荐）
openclaw config set env.ANTHROPIC_API_KEY "your-key"

# 3. 重启 Gateway
systemctl restart openclaw-gateway.service
```

---

### 问题 6：Nginx 502 错误

**症状：**
访问 Control UI 返回 502 Bad Gateway

**解决方案：**
```bash
# 1. 检查 Gateway 是否运行
systemctl status openclaw-gateway.service

# 2. 检查端口监听
ss -tlnp | grep 18789

# 3. 查看 Nginx 错误日志
tail -f /var/log/nginx/openclaw-error.log

# 4. 测试配置
nginx -t

# 5. 重启服务
systemctl restart openclaw-gateway.service
systemctl reload nginx
```

---

### 问题 7：Telegram Bot 不响应

**症状：**
发送消息给 Bot 没有回复

**解决方案：**
```bash
# 1. 检查 Telegram 配置
openclaw config get channels.telegram

# 2. 查看日志
openclaw logs --follow

# 3. 检查配对状态
openclaw pairing list

# 4. 批准配对请求
openclaw pairing approve <request-id>

# 5. 配置白名单（如果使用 allowlist 模式）
openclaw config set channels.telegram.allowFrom '["USER_ID"]'
```

---

### 问题 8：WebSocket 连接失败

**症状：**
Control UI 无法连接 WebSocket

**解决方案：**
```bash
# 1. 检查 Nginx 配置
nginx -t

# 2. 验证 WebSocket 路径
curl -I http://127.0.0.1:9000/openclaw/ws

# 3. 检查 Nginx 日志
tail -f /var/log/nginx/openclaw-error.log

# 4. 测试直连
curl -I http://127.0.0.1:18789/

# 5. 重载 Nginx
systemctl reload nginx
```

---

## 🔐 安全建议

### 1. 定期更新 Gateway Token

```bash
# 生成新 Token
NEW_TOKEN=$(openssl rand -hex 24)

# 更新配置
openclaw config set gateway.auth.token "$NEW_TOKEN"

# 重启服务
systemctl restart openclaw-gateway.service

# 保存新 Token
echo "Gateway Token: $NEW_TOKEN" >> /root/openclaw-tool/config.txt
```

### 2. 配置 Telegram 白名单

```bash
# 1. 发送消息给 Bot
# 2. 查看日志获取用户 ID
openclaw logs --follow

# 3. 添加到白名单
openclaw config set channels.telegram.allowFrom '["USER_ID_1", "USER_ID_2"]'

# 4. 重启 Gateway
systemctl restart openclaw-gateway.service
```

### 3. 限制 Nginx 访问

```bash
# 编辑 Nginx 配置
nano /etc/nginx/sites-available/openclaw-gateway.conf

# 添加 IP 白名单
location /openclaw/ {
    allow 100.64.0.0/10;  # Tailscale
    allow 127.0.0.1;       # 本地
    deny all;
    ...
}

# 重载配置
nginx -t && systemctl reload nginx
```

---

## 📊 监控与维护

### 日志轮转

```bash
# 创建日志轮转配置
cat > /etc/logrotate.d/openclaw <<EOF
/tmp/openclaw/*.log {
    daily
    rotate 7
    compress
    delaycompress
    missingok
    notifempty
}
EOF
```

### 定期备份配置

```bash
# 创建备份脚本
cat > /root/openclaw-tool/backup.sh <<'EOF'
#!/bin/bash
BACKUP_DIR="/root/openclaw-backups"
DATE=$(date +%Y%m%d-%H%M%S)

mkdir -p "$BACKUP_DIR"

# 备份配置文件
cp /root/.openclaw/openclaw.json "$BACKUP_DIR/openclaw-$DATE.json"
cp /etc/nginx/sites-available/openclaw-gateway.conf "$BACKUP_DIR/nginx-$DATE.conf"

# 保留最近 30 天的备份
find "$BACKUP_DIR" -name "*.json" -mtime +30 -delete
find "$BACKUP_DIR" -name "*.conf" -mtime +30 -delete

echo "Backup completed: $DATE"
EOF

chmod +x /root/openclaw-tool/backup.sh

# 添加到 crontab（每天凌晨 2 点备份）
(crontab -l 2>/dev/null; echo "0 2 * * * /root/openclaw-tool/backup.sh") | crontab -
```

### 健康检查

```bash
# 创建健康检查脚本
cat > /root/openclaw-tool/healthcheck.sh <<'EOF'
#!/bin/bash
export PATH="/root/.local/share/fnm/node-versions/v24.13.0/installation/bin:$PATH"

if ! openclaw gateway probe > /dev/null 2>&1; then
    echo "Gateway unhealthy, restarting..."
    systemctl restart openclaw-gateway.service
    sleep 5

    if openclaw gateway probe > /dev/null 2>&1; then
        echo "Gateway recovered"
    else
        echo "Gateway still unhealthy, manual intervention required"
        # 可以在这里添加告警通知
    fi
fi
EOF

chmod +x /root/openclaw-tool/healthcheck.sh

# 添加到 crontab（每 5 分钟检查一次）
(crontab -l 2>/dev/null; echo "*/5 * * * * /root/openclaw-tool/healthcheck.sh") | crontab -
```

---

## 🌐 Tailscale 配置

### 启动 Tailscale

```bash
# 启动并登录
tailscale up

# 配置反向代理
tailscale serve https / http://127.0.0.1:9000

# 查看状态
tailscale status

# 获取访问地址
tailscale serve status
```

### 访问地址

```
Control UI: https://your-device.tailscale.net/openclaw/
WebSocket:  wss://your-device.tailscale.net/openclaw/ws
```

---

## 📞 获取帮助

### 官方文档

- OpenClaw 文档: https://docs.openclaw.ai/
- Telegram 配置: https://docs.openclaw.ai/zh-CN/channels/telegram
- Gateway 配置: https://docs.openclaw.ai/zh-CN/gateway

### 故障排查

1. 运行故障排查工具
   ```bash
   bash /root/openclaw-tool/openclaw-troubleshoot.sh
   ```

2. 收集诊断信息
   ```bash
   bash /root/openclaw-tool/openclaw-troubleshoot.sh
   # 选择 "7. 收集诊断信息"
   ```

3. 查看部署总结
   ```bash
   cat /root/openclaw-tool/DEPLOYMENT_SUMMARY.md
   ```

---

## 📝 更新日志

### v1.1.0 (2026-03-06)
- ✅ 添加部署后问题文档 (POST_DEPLOYMENT_ISSUES.md)
- ✅ 添加 Tailscale 路由修复脚本
- ✅ 添加 Gateway Origin 修复脚本
- ✅ 添加 Gateway Token 重置脚本
- ✅ 更新常见问题解决方案

### v1.0.0 (2026-03-06)
- ✅ 初始版本
- ✅ 一键部署脚本
- ✅ 故障排查工具
- ✅ 完整文档

---

## 🎉 总结

这套工具集提供了：
- **一键部署**：快速安装和配置 OpenClaw
- **故障排查**：自动诊断和修复常见问题
- **完整文档**：详细的使用说明和最佳实践
- **维护脚本**：备份、监控、健康检查

**建议：**
1. 首次部署使用 `openclaw-deploy.sh`
2. 遇到问题使用 `openclaw-troubleshoot.sh`
3. 定期查看 `DEPLOYMENT_SUMMARY.md` 了解最佳实践
4. 配置自动备份和健康检查

**祝你使用愉快！** 🚀
