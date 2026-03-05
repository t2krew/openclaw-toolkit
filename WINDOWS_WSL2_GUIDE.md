# Windows WSL2 部署指南

本指南将帮助你在 Windows 上通过 WSL2 部署 OpenClaw Gateway。

## 为什么使用 WSL2？

WSL2 (Windows Subsystem for Linux 2) 提供了完整的 Linux 环境：
- ✅ 完整的 Linux 内核
- ✅ 支持 systemd
- ✅ 性能接近原生 Linux
- ✅ 可以直接使用 Linux 部署脚本
- ✅ 无需虚拟机

## 前置要求

- Windows 10 版本 2004 及更高版本（内部版本 19041 及更高版本）或 Windows 11
- 管理员权限

## 步骤 1: 安装 WSL2

### 方法 1: 一键安装（推荐）

打开 PowerShell（管理员），运行：

```powershell
wsl --install
```

这将：
- 启用 WSL 功能
- 安装 Ubuntu（默认）
- 重启计算机

### 方法 2: 手动安装

如果一键安装失败，按照以下步骤：

1. **启用 WSL 功能**

```powershell
dism.exe /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all /norestart
```

2. **启用虚拟机平台**

```powershell
dism.exe /online /enable-feature /featurename:VirtualMachinePlatform /all /norestart
```

3. **重启计算机**

4. **下载并安装 WSL2 Linux 内核更新包**

访问: https://aka.ms/wsl2kernel

5. **设置 WSL2 为默认版本**

```powershell
wsl --set-default-version 2
```

6. **安装 Ubuntu**

```powershell
wsl --install -d Ubuntu
```

## 步骤 2: 配置 Ubuntu

1. **首次启动 Ubuntu**

在开始菜单搜索 "Ubuntu" 并启动。

2. **创建用户账户**

按提示创建用户名和密码。

3. **更新系统**

```bash
sudo apt update && sudo apt upgrade -y
```

## 步骤 3: 部署 OpenClaw

在 Ubuntu (WSL2) 中运行：

```bash
# 克隆仓库
git clone https://github.com/t2krew/openclaw-toolkit.git
cd openclaw-toolkit

# 运行 Linux 部署脚本
sudo bash openclaw-deploy.sh
```

就这么简单！脚本会自动完成所有配置。

## 步骤 4: 访问服务

### 从 Windows 访问

WSL2 的服务可以从 Windows 直接访问：

- **Control UI**: http://localhost:9000/openclaw/
- **WebSocket**: ws://localhost:9000/openclaw/ws

### 从 WSL2 内部访问

- **Control UI**: http://127.0.0.1:9000/openclaw/
- **WebSocket**: ws://127.0.0.1:9000/openclaw/ws

## 常用命令

### 启动 WSL2

```powershell
# 从 Windows PowerShell
wsl
```

### 停止 WSL2

```powershell
# 从 Windows PowerShell
wsl --shutdown
```

### 查看 WSL2 状态

```powershell
wsl --list --verbose
```

### 在 WSL2 中管理服务

```bash
# 查看 OpenClaw 状态
sudo systemctl status openclaw-gateway.service

# 重启 OpenClaw
sudo systemctl restart openclaw-gateway.service

# 查看日志
sudo journalctl -u openclaw-gateway.service -f

# 查看 Nginx 状态
sudo systemctl status nginx
```

## 文件访问

### 从 Windows 访问 WSL2 文件

在 Windows 文件资源管理器中输入：

```
\\wsl$\Ubuntu\home\你的用户名\
```

### 从 WSL2 访问 Windows 文件

Windows 驱动器挂载在 `/mnt/` 下：

```bash
cd /mnt/c/Users/你的用户名/
```

## 自动启动

### 方法 1: Windows 启动时自动启动 WSL2

创建文件 `C:\Users\你的用户名\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Startup\start-wsl.vbs`

内容：

```vbscript
Set ws = CreateObject("Wscript.Shell")
ws.run "wsl -d Ubuntu -u root service openclaw-gateway start", vbhide
ws.run "wsl -d Ubuntu -u root service nginx start", vbhide
```

### 方法 2: 使用 Windows 任务计划程序

1. 打开任务计划程序
2. 创建基本任务
3. 触发器：登录时
4. 操作：启动程序
5. 程序：`wsl`
6. 参数：`-d Ubuntu -u root service openclaw-gateway start && service nginx start`

## Tailscale 配置

如果你在部署时选择了 Tailscale：

1. **在 Windows 上安装 Tailscale**

访问: https://tailscale.com/download/windows

2. **在 WSL2 中配置路由**

Tailscale 已经在部署脚本中自动配置。

3. **访问**

通过 Tailscale 域名访问：`https://你的设备名.tailnet域名/openclaw/`

## 故障排查

### WSL2 无法启动

```powershell
# 重启 WSL2
wsl --shutdown
wsl
```

### 服务无法访问

```bash
# 检查服务状态
sudo systemctl status openclaw-gateway.service
sudo systemctl status nginx

# 检查端口
sudo netstat -tlnp | grep 9000
```

### 网络问题

```bash
# 重启网络
sudo systemctl restart systemd-networkd
```

### 查看详细日志

```bash
# OpenClaw 日志
sudo journalctl -u openclaw-gateway.service -n 100

# Nginx 日志
sudo tail -f /var/log/nginx/openclaw-error.log
```

## 性能优化

### 限制 WSL2 内存使用

创建文件 `C:\Users\你的用户名\.wslconfig`

内容：

```ini
[wsl2]
memory=4GB
processors=2
swap=2GB
```

重启 WSL2 使配置生效：

```powershell
wsl --shutdown
```

## 卸载

### 卸载 OpenClaw

在 WSL2 中：

```bash
cd openclaw-toolkit
sudo bash openclaw-troubleshoot.sh
# 选择卸载选项
```

### 卸载 WSL2

在 PowerShell（管理员）中：

```powershell
# 卸载 Ubuntu
wsl --unregister Ubuntu

# 禁用 WSL
dism.exe /online /disable-feature /featurename:Microsoft-Windows-Subsystem-Linux
dism.exe /online /disable-feature /featurename:VirtualMachinePlatform
```

## 常见问题

### Q: WSL2 和虚拟机有什么区别？

A: WSL2 更轻量，启动更快，与 Windows 集成更好，性能更接近原生。

### Q: 可以同时运行多个 Linux 发行版吗？

A: 可以。使用 `wsl --install -d 发行版名称` 安装其他发行版。

### Q: WSL2 占用多少空间？

A: Ubuntu 基础安装约 1-2GB，加上 OpenClaw 和依赖约 3-4GB。

### Q: 可以在 WSL2 中使用 GPU 吗？

A: 可以，WSL2 支持 GPU 加速（需要 Windows 11 或 Windows 10 特定版本）。

### Q: 数据会丢失吗？

A: 不会。WSL2 的数据持久化存储，除非手动删除。

## 更多资源

- **WSL2 官方文档**: https://docs.microsoft.com/zh-cn/windows/wsl/
- **OpenClaw 文档**: https://docs.openclaw.ai/
- **本项目 GitHub**: https://github.com/t2krew/openclaw-toolkit

## 支持

如有问题，请在 GitHub 提交 Issue：
https://github.com/t2krew/openclaw-toolkit/issues

---

**版本**: v2.2.0
**更新时间**: 2026-03-06
**适用于**: Windows 10/11 + WSL2 + Ubuntu
