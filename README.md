# OpenClaw Deployment Toolkit

**[English](README.md)** | [中文](README_CN.md)

---

**One-click deployment toolkit for OpenClaw Gateway** - Automated installation, configuration, and management.

## 🎯 Features

- **True One-Click Deployment** - All configurations done correctly from the start
- **No Manual Fixes Required** - Deploy once, use immediately
- **Cross-Platform Support** - Works on Debian, Ubuntu, CentOS, RHEL, Arch Linux
- **Complete Dependency Management** - Automatically installs everything needed
- **Intelligent Troubleshooting** - Automatic problem detection and diagnosis
- **Best Practices Built-in** - Based on real-world deployment experience

## 🚀 Quick Start

```bash
# Clone the repository
git clone https://github.com/t2krew/openclaw-toolkit.git
cd openclaw-toolkit

# One-click deployment - that's it!
bash openclaw-deploy.sh
```

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

## 📦 What's Included

- **openclaw-deploy.sh** - One-click deployment script (all you need!)
- **openclaw-troubleshoot.sh** - Diagnostic and troubleshooting tool
- **README.md** - English documentation
- **README_CN.md** - Chinese documentation
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
