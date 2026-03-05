# OpenClaw Deployment Toolkit

**[English](README.md)** | [中文](README_CN.md)

---

**Production-ready deployment toolkit for OpenClaw Gateway** - Automated installation, configuration, and management with Nginx, Tailscale, and service management.

## 🎯 Features

- **Docker Support** - Easiest deployment method for all platforms
- **Cross-Platform** - Linux, macOS, Windows (WSL2)
- **Complete Automation** - One command to deploy everything
- **Production Ready** - Nginx, Tailscale, service management included
- **Best Practices** - Based on real-world deployment experience

## 🚀 Quick Start

### Docker (Recommended) 🐳

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
# In PowerShell (Administrator)
wsl --install
# After reboot, in Ubuntu:
git clone https://github.com/t2krew/openclaw-toolkit.git
cd openclaw-toolkit
sudo bash openclaw-deploy.sh
```

For detailed Windows instructions, see [WINDOWS_WSL2_GUIDE.md](WINDOWS_WSL2_GUIDE.md).

## 💻 System Requirements

### Docker Deployment (Recommended)
- Docker 20.10+
- Docker Compose 2.0+
- Works on: Linux, macOS, Windows

### Native Deployment

**Linux:**
- Debian 10+ / Ubuntu 20.04+
- CentOS 7+ / RHEL 8+
- Arch Linux / Manjaro

**macOS:**
- macOS 10.15 (Catalina) or later
- Intel or Apple Silicon (M1/M2/M3)

**Windows:**
- Windows 10 version 2004+ or Windows 11
- WSL2 with Ubuntu/Debian

## 📦 What This Toolkit Does

**Complete production deployment:**
- ✅ Install OpenClaw Gateway
- ✅ Configure Nginx reverse proxy
- ✅ Set up Tailscale network (optional)
- ✅ Configure service management (systemd/launchd)
- ✅ Set up security (token auth, origin whitelist)
- ✅ Enable auto-start on boot

## 📁 What's Included

### Deployment Scripts
- **docker-compose.yml** - Docker Compose configuration (recommended)
- **Dockerfile** - OpenClaw Gateway Docker image
- **openclaw-deploy.sh** - Linux native deployment script
- **openclaw-deploy-macos.sh** - macOS native deployment script
- **install-wsl2.ps1** - Windows WSL2 setup helper (PowerShell)

### Uninstall Scripts
- **docker-uninstall.sh** - Docker uninstall script
- **openclaw-uninstall.sh** - Native uninstall script (Linux/macOS)
- **windows-uninstall.ps1** - Windows WSL2 uninstall script (PowerShell)

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

**Docker Deployment:**
```
Docker Compose
├── openclaw-gateway (container)
├── nginx (container)
└── tailscale (optional)
```

**Native Deployment:**
```
Internet
   ↓
Tailscale Network (HTTPS)
   ↓
Nginx (127.0.0.1:9000)
   ├── /openclaw/         → OpenClaw Control UI
   └── /openclaw/ws       → OpenClaw WebSocket
```

## 🔧 Troubleshooting

**Docker:**
```bash
# View logs
docker-compose logs -f

# Restart services
docker-compose restart

# Check status
docker-compose ps
```

**Native:**
```bash
# Run troubleshooting tool
bash openclaw-troubleshoot.sh

# Check service status (Linux)
systemctl status openclaw-gateway.service

# Check service status (macOS)
launchctl list | grep openclaw
```

## 🗑️ Uninstall

**Docker:**
```bash
# Run Docker uninstall script
bash docker-uninstall.sh

# Or manually
docker-compose down -v  # Remove containers and volumes
```

**Native (Linux/macOS):**
```bash
# Run uninstall script
bash openclaw-uninstall.sh

# The script will:
# - Stop all services
# - Remove service files
# - Clean up Nginx configuration
# - Uninstall OpenClaw Gateway
# - Optionally remove config/data
# - Optionally uninstall dependencies
```

**Windows (WSL2):**
```powershell
# In PowerShell
.\windows-uninstall.ps1

# The script will:
# - Uninstall OpenClaw in WSL2 Ubuntu
# - Optionally remove config/data
# - Optionally uninstall WSL2 and Ubuntu
```

## 📞 Support

- **GitHub Issues**: https://github.com/t2krew/openclaw-toolkit/issues
- **Official Docs**: https://docs.openclaw.ai/

## 📝 License

MIT License

---

**Version**: v2.4.0
**Last Updated**: 2026-03-06
**Repository**: https://github.com/t2krew/openclaw-toolkit
