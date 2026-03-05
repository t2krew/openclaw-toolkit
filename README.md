# OpenClaw Deployment Toolkit

**[English](README.md)** | [中文](README_CN.md)

---

**Production-ready deployment toolkit for OpenClaw Gateway on Linux servers** - Automated installation, configuration, and management with Nginx, Tailscale, and systemd.

> **Note**: This toolkit is designed for **Linux server production deployments**. For macOS/Windows development environments, please use the [official installer](https://docs.openclaw.ai/install).

## 🎯 Features

- **True One-Click Deployment** - All configurations done correctly from the start
- **No Manual Fixes Required** - Deploy once, use immediately
- **Cross-Platform Support** - Works on Debian, Ubuntu, CentOS, RHEL, Arch Linux
- **Complete Dependency Management** - Automatically installs everything needed
- **Intelligent Troubleshooting** - Automatic problem detection and diagnosis
- **Best Practices Built-in** - Based on real-world deployment experience

## 🚀 Quick Start

### Docker (Recommended for all platforms) 🐳

**The easiest way to deploy on any platform:**

```bash
# Clone the repository
git clone https://github.com/t2krew/openclaw-toolkit.git
cd openclaw-toolkit

# Configure environment variables
cp .env.example .env
# Edit .env and add your API keys

# Start all services
docker-compose up -d

# Access Control UI
# http://localhost:9000/openclaw/
```

**Why Docker?**
- ✅ Works on Linux, macOS, Windows
- ✅ No need to install Node.js, Nginx, etc.
- ✅ Isolated environment
- ✅ Easy to manage and update
- ✅ One command to start everything

For detailed instructions, see [DOCKER_GUIDE.md](DOCKER_GUIDE.md).

### Native Installation

**Linux:**
```bash
# Clone the repository
git clone https://github.com/t2krew/openclaw-toolkit.git
cd openclaw-toolkit

# One-click deployment
sudo bash openclaw-deploy.sh
```

**macOS:**
```bash
# Clone the repository
git clone https://github.com/t2krew/openclaw-toolkit.git
cd openclaw-toolkit

# One-click deployment
bash openclaw-deploy-macos.sh
```

## 💻 System Requirements

### Supported Linux Distributions

This toolkit supports the following Linux distributions:

- ✅ **Debian** 10+
- ✅ **Ubuntu** 20.04+
- ✅ **CentOS** 7+
- ✅ **RHEL** 8+
- ✅ **Arch Linux**
- ✅ **Manjaro**

### macOS Support

**NEW!** We now provide a complete macOS deployment script with full production features:

```bash
# macOS deployment (includes Nginx, Tailscale, launchd)
bash openclaw-deploy-macos.sh
```

**Features on macOS:**
- ✅ Complete production deployment (same as Linux)
- ✅ Nginx reverse proxy configuration
- ✅ Tailscale network setup
- ✅ launchd service management (instead of systemd)
- ✅ Homebrew package management
- ✅ All security configurations

**macOS Requirements:**
- macOS 10.15 (Catalina) or later
- Administrator privileges
- Internet connection

### Windows Users

**For Windows**, we recommend using WSL2 (Windows Subsystem for Linux):

**Quick Setup:**

1. Download and run the setup script:
   ```powershell
   # In PowerShell (Administrator)
   iwr -useb https://raw.githubusercontent.com/t2krew/openclaw-toolkit/main/install-wsl2.ps1 | iex
   ```

2. Or manually install WSL2:
   ```powershell
   # In PowerShell (Administrator)
   wsl --install
   ```

3. After reboot, in Ubuntu (WSL2):
   ```bash
   git clone https://github.com/t2krew/openclaw-toolkit.git
   cd openclaw-toolkit
   sudo bash openclaw-deploy.sh
   ```

**Why WSL2?**
- ✅ Full Linux environment on Windows
- ✅ Native performance
- ✅ Complete systemd support
- ✅ Use the same Linux deployment script
- ✅ No virtual machine needed

**Access from Windows:**
- Control UI: http://localhost:9000/openclaw/
- WebSocket: ws://localhost:9000/openclaw/ws

For detailed instructions, see [WINDOWS_WSL2_GUIDE.md](WINDOWS_WSL2_GUIDE.md).

**Alternative:** For development-only setup without Nginx/Tailscale, use the official installer:
```powershell
iwr -useb https://openclaw.ai/install.ps1 | iex
```

For more information, see the [official installation guide](https://docs.openclaw.ai/install).

## 📦 What This Toolkit Does

## 📦 What This Toolkit Does

**That's all you need!** The deployment script will:
- ✅ Check network connection
- ✅ Install all dependencies (including jq, nginx, etc.)
- ✅ Install Node.js via fnm
- ✅ Install OpenClaw Gateway
- ✅ Configure OpenClaw with your API keys
- ✅ Set up Nginx reverse proxy with correct WebSocket paths
- ✅ Configure Tailscale routing (if selected)
- ✅ Set up Gateway allowedOrigins automatically
- ✅ Create systemd service for auto-start
- ✅ Verify everything works

**This is a complete production deployment**, not just an installer. It includes:
- Nginx reverse proxy configuration
- Tailscale network setup
- systemd service management
- Security configurations (token auth, origin whitelist)

## 📁 What's Included

### Deployment Scripts
- **docker-compose.yml** - Docker Compose configuration (recommended)
- **Dockerfile** - OpenClaw Gateway Docker image
- **openclaw-deploy.sh** - Linux native deployment script
- **openclaw-deploy-macos.sh** - macOS native deployment script
- **install-wsl2.ps1** - Windows WSL2 setup helper (PowerShell)

### Configuration Files
- **nginx.conf** - Nginx reverse proxy configuration
- **.env.example** - Environment variables template

### Tools & Documentation
- **openclaw-troubleshoot.sh** - Diagnostic and troubleshooting tool
- **README.md** - English documentation
- **README_CN.md** - Chinese documentation
- **DOCKER_GUIDE.md** - Docker deployment guide
- **WINDOWS_WSL2_GUIDE.md** - Windows WSL2 guide
- **CHANGELOG.md** - Version history
- **LICENSE** - MIT License

## 🌐 Architecture

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

## 🎓 Built-in Best Practices

The deployment script automatically implements:
- ✅ **Dynamic Path Resolution** - No hardcoded paths, works with any Node.js version
- ✅ **Cross-Platform Nginx** - Supports both Debian/Ubuntu and CentOS/RHEL directory structures
- ✅ **Complete Error Handling** - Every step is checked, with cleanup on failure
- ✅ **WebSocket Reverse Proxy** - Unified path prefix design
- ✅ **API Key Management** - Environment variable approach
- ✅ **Tailscale Configuration** - All traffic through Nginx with correct routing
- ✅ **Gateway Security** - Token authentication and origin whitelist
- ✅ **Service Management** - Systemd integration for reliability

## 🔧 Troubleshooting

If you encounter any issues:

```bash
# Run the troubleshooting tool
bash openclaw-troubleshoot.sh

# Check service status
systemctl status openclaw-gateway.service

# View logs
journalctl -u openclaw-gateway.service -f
```

## 📞 Support

- **Official Docs**: https://docs.openclaw.ai/
- **Troubleshooting**: https://docs.openclaw.ai/troubleshooting
- **Issues**: https://github.com/t2krew/openclaw-toolkit/issues

## 📝 License

MIT License

## 🙏 Acknowledgments

Developed during the deployment of OpenClaw Gateway on Raspberry Pi (ARM64).

---

**Version**: v2.0.0
**Last Updated**: 2026-03-06
**Repository**: https://github.com/t2krew/openclaw-toolkit
