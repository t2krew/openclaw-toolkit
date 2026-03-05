# OpenClaw 部署后续问题与解决方案

**更新时间：** 2026-03-06
**版本：** 1.1.0

---

## 🐛 部署后发现的问题

### 问题 1：Tailscale Serve 路由配置错误 ⭐⭐⭐⭐

**问题描述：**
```
https://raspberrypi.tailcc9b33.ts.net
|-- / proxy http://127.0.0.1:18789  ← 错误！直接暴露 Gateway

http://raspberrypi.tailcc9b33.ts.net
|-- / proxy http://127.0.0.1:9000   ← 正确！通过 Nginx
```

**问题表现：**
- HTTPS (443) 直接代理到 Gateway (18789)，绕过了 Nginx
- HTTP (80) 代理到 Nginx (9000)
- 配置不一致，导致 WebSocket 路径混乱

**根本原因：**
- 之前可能手动执行过错误的配置命令
- 旧配置没有被清理
- Tailscale Serve 的 HTTPS 和 HTTP 指向了不同的端口

**解决方案：**

```bash
# 1. 重置所有 Tailscale Serve 配置
tailscale serve reset

# 2. 配置 HTTPS (443) 代理到 Nginx
tailscale serve --bg http://127.0.0.1:9000

# 3. 配置 HTTP (80) 代理到 Nginx
tailscale serve --http=80 --bg http://127.0.0.1:9000

# 4. 验证配置
tailscale serve status
```

**正确的配置结果：**
```
https://raspberrypi.tailcc9b33.ts.net (tailnet only)
|-- / proxy http://127.0.0.1:9000

http://raspberrypi.tailcc9b33.ts.net (tailnet only)
|-- / proxy http://127.0.0.1:9000
```

**验证配置：**
```bash
# 查看详细配置
tailscale serve status --json
```

**预期输出：**
```json
{
  "TCP": {
    "443": { "HTTPS": true },
    "80": { "HTTP": true }
  },
  "Web": {
    "raspberrypi.tailcc9b33.ts.net:443": {
      "Handlers": {
        "/": { "Proxy": "http://127.0.0.1:9000" }
      }
    },
    "raspberrypi.tailcc9b33.ts.net:80": {
      "Handlers": {
        "/": { "Proxy": "http://127.0.0.1:9000" }
      }
    }
  }
}
```

**关键要点：**
- ✅ 所有外部请求都必须通过 Nginx
- ✅ 80 和 443 端口都代理到同一个地址 (9000)
- ✅ 不要直接暴露 Gateway 端口 (18789)

---

### 问题 2：Gateway Origin 不允许错误 ⭐⭐⭐⭐

**问题描述：**
```
origin not allowed (open the Control UI from the gateway host or allow it in gateway.controlUi.allowedOrigins)
```

**问题表现：**
- 通过 Tailscale 域名访问 Control UI 时被拒绝
- WebSocket 连接失败
- 浏览器控制台显示 CORS 错误

**根本原因：**
- Gateway 默认只允许从本地主机访问
- Tailscale 域名不在允许的来源列表中
- `gateway.controlUi.allowedOrigins` 配置缺失

**解决方案：**

```bash
# 1. 添加 Tailscale 域名到允许列表
openclaw config set gateway.controlUi.allowedOrigins '["https://your-device.tailscale.net"]'

# 2. 重启 Gateway 应用配置
pkill -f "openclaw-gateway"
openclaw gateway run > /tmp/gateway.log 2>&1 &

# 3. 等待启动完成
sleep 10

# 4. 验证配置
openclaw config get gateway.controlUi.allowedOrigins
openclaw gateway probe
```

**配置示例：**
```json
{
  "gateway": {
    "controlUi": {
      "allowedOrigins": [
        "https://raspberrypi.tailcc9b33.ts.net"
      ]
    }
  }
}
```

**多域名配置：**
```bash
# 如果需要允许多个域名
openclaw config set gateway.controlUi.allowedOrigins '[
  "https://raspberrypi.tailcc9b33.ts.net",
  "https://another-device.tailscale.net"
]'
```

**关键要点：**
- ✅ 必须使用完整的 HTTPS URL
- ✅ 不要包含路径，只需要协议和域名
- ✅ 修改后必须重启 Gateway

---

### 问题 3：Gateway 认证失败锁定 ⭐⭐⭐

**问题描述：**
```
unauthorized: too many failed authentication attempts (retry later)
```

**问题表现：**
- 访问 Control UI 时提示认证失败
- 即使输入正确的 Token 也无法访问
- 需要等待一段时间才能重试

**根本原因：**
- Gateway 启用了 Token 认证
- 浏览器没有正确的 Token 或 Token 过期
- 多次认证失败触发了速率限制

**解决方案：**

**方案 A：获取正确的 Token**
```bash
# 1. 查看当前 Token
openclaw config get gateway.auth.token

# 2. 访问 Control UI 时在 URL 中添加 Token
https://your-device.tailscale.net/openclaw/?token=YOUR_TOKEN
```

**方案 B：重新生成 Token**
```bash
# 1. 生成新的 Token
NEW_TOKEN=$(openssl rand -hex 24)

# 2. 更新配置
openclaw config set gateway.auth.token "$NEW_TOKEN"

# 3. 重启 Gateway
pkill -f "openclaw-gateway"
openclaw gateway run > /tmp/gateway.log 2>&1 &

# 4. 保存新 Token
echo "Gateway Token: $NEW_TOKEN" >> /root/openclaw-tool/config.txt
echo "访问地址: https://your-device.tailscale.net/openclaw/?token=$NEW_TOKEN"
```

**方案 C：临时禁用认证（不推荐）**
```bash
# 仅用于调试，不要在生产环境使用
openclaw config set gateway.auth.mode "none"
pkill -f "openclaw-gateway"
openclaw gateway run > /tmp/gateway.log 2>&1 &
```

**等待锁定解除：**
- 速率限制通常在 5-10 分钟后自动解除
- 或者重启 Gateway 立即解除

**关键要点：**
- ✅ Token 认证是重要的安全措施
- ✅ 将 Token 保存在安全的地方
- ✅ 定期更换 Token
- ✅ 不要在公开场合分享 Token

---

## 🔧 快速修复脚本

### 修复 Tailscale 路由配置

```bash
#!/bin/bash
# 文件: /root/openclaw-tool/fix-tailscale-routing.sh

echo "修复 Tailscale Serve 路由配置..."

# 重置配置
tailscale serve reset

# 配置 HTTPS
tailscale serve --bg http://127.0.0.1:9000

# 配置 HTTP
tailscale serve --http=80 --bg http://127.0.0.1:9000

# 验证
echo ""
echo "当前配置:"
tailscale serve status

echo ""
echo "✅ Tailscale 路由配置已修复"
```

### 修复 Gateway Origin 配置

```bash
#!/bin/bash
# 文件: /root/openclaw-tool/fix-gateway-origin.sh

export PATH="/root/.local/share/fnm/node-versions/v24.13.0/installation/bin:$PATH"

echo "修复 Gateway Origin 配置..."

# 获取 Tailscale 域名
TAILSCALE_DOMAIN=$(tailscale status --json | jq -r '.Self.DNSName' | sed 's/\.$//')

if [ -z "$TAILSCALE_DOMAIN" ]; then
    echo "❌ 无法获取 Tailscale 域名"
    exit 1
fi

echo "Tailscale 域名: https://$TAILSCALE_DOMAIN"

# 添加到允许列表
openclaw config set gateway.controlUi.allowedOrigins "[\"https://$TAILSCALE_DOMAIN\"]"

# 重启 Gateway
echo "重启 Gateway..."
pkill -f "openclaw-gateway"
sleep 2
openclaw gateway run > /tmp/gateway.log 2>&1 &

# 等待启动
echo "等待 Gateway 启动..."
sleep 10

# 验证
openclaw gateway probe

echo ""
echo "✅ Gateway Origin 配置已修复"
echo "访问地址: https://$TAILSCALE_DOMAIN/openclaw/"
```

### 重置 Gateway Token

```bash
#!/bin/bash
# 文件: /root/openclaw-tool/reset-gateway-token.sh

export PATH="/root/.local/share/fnm/node-versions/v24.13.0/installation/bin:$PATH"

echo "重置 Gateway Token..."

# 生成新 Token
NEW_TOKEN=$(openssl rand -hex 24)

# 更新配置
openclaw config set gateway.auth.token "$NEW_TOKEN"

# 重启 Gateway
echo "重启 Gateway..."
pkill -f "openclaw-gateway"
sleep 2
openclaw gateway run > /tmp/gateway.log 2>&1 &

# 等待启动
echo "等待 Gateway 启动..."
sleep 10

# 获取 Tailscale 域名
TAILSCALE_DOMAIN=$(tailscale status --json | jq -r '.Self.DNSName' | sed 's/\.$//')

# 保存配置
echo "" >> /root/openclaw-tool/config.txt
echo "=== Token 更新 $(date) ===" >> /root/openclaw-tool/config.txt
echo "Gateway Token: $NEW_TOKEN" >> /root/openclaw-tool/config.txt

echo ""
echo "✅ Gateway Token 已重置"
echo ""
echo "新 Token: $NEW_TOKEN"
echo ""
echo "访问地址:"
echo "https://$TAILSCALE_DOMAIN/openclaw/?token=$NEW_TOKEN"
```

---

## 📋 完整的故障排查流程

### 1. Tailscale 访问问题

**症状：**
- 无法通过 Tailscale 域名访问
- 页面加载失败或超时

**排查步骤：**
```bash
# 1. 检查 Tailscale 状态
tailscale status

# 2. 检查 Tailscale Serve 配置
tailscale serve status

# 3. 检查 Nginx 状态
systemctl status nginx
curl -I http://127.0.0.1:9000/health

# 4. 检查 Gateway 状态
openclaw gateway probe
```

**修复：**
```bash
bash /root/openclaw-tool/fix-tailscale-routing.sh
```

---

### 2. Origin 不允许错误

**症状：**
- 浏览器控制台显示 CORS 错误
- WebSocket 连接失败
- 提示 "origin not allowed"

**排查步骤：**
```bash
# 1. 检查允许的来源
openclaw config get gateway.controlUi.allowedOrigins

# 2. 检查 Tailscale 域名
tailscale status | grep DNSName
```

**修复：**
```bash
bash /root/openclaw-tool/fix-gateway-origin.sh
```

---

### 3. 认证失败问题

**症状：**
- 提示 "unauthorized"
- 提示 "too many failed authentication attempts"

**排查步骤：**
```bash
# 1. 检查认证模式
openclaw config get gateway.auth.mode

# 2. 查看 Gateway 日志
tail -f /tmp/openclaw/openclaw-$(date +%Y-%m-%d).log | grep -i "auth\|unauthorized"
```

**修复：**
```bash
# 方案 1: 重置 Token
bash /root/openclaw-tool/reset-gateway-token.sh

# 方案 2: 等待 5-10 分钟后重试

# 方案 3: 重启 Gateway
pkill -f "openclaw-gateway"
openclaw gateway run > /tmp/gateway.log 2>&1 &
```

---

## 🎓 经验总结

### 最佳实践

1. **Tailscale 配置**
   - ✅ 始终通过 Nginx 统一管理
   - ✅ 80 和 443 端口配置一致
   - ✅ 不要直接暴露后端服务端口

2. **Gateway 安全**
   - ✅ 启用 Token 认证
   - ✅ 配置 allowedOrigins 白名单
   - ✅ 定期更换 Token
   - ✅ 保存 Token 到安全位置

3. **故障排查**
   - ✅ 从外到内逐层检查（Tailscale → Nginx → Gateway）
   - ✅ 查看日志获取详细错误信息
   - ✅ 使用提供的修复脚本快速解决

### 避免的错误

1. ❌ 不要直接暴露 Gateway 端口 (18789)
2. ❌ 不要忘记配置 allowedOrigins
3. ❌ 不要在公开场合分享 Token
4. ❌ 不要禁用认证（除非调试）

---

## 📚 相关文档

- Tailscale Serve 文档: https://tailscale.com/kb/1242/tailscale-serve
- OpenClaw Gateway 配置: https://docs.openclaw.ai/zh-CN/gateway
- OpenClaw 安全配置: https://docs.openclaw.ai/zh-CN/security

---

**更新日志：**
- v1.1.0 (2026-03-06) - 添加部署后发现的问题和解决方案
- v1.0.0 (2026-03-06) - 初始版本

**维护者：** Claude (Kiro AI Assistant)
