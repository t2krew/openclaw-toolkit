# OpenClaw Deployment Toolkit

**[English](README.md)** | [中文](README_CN.md)

---

**One-click deployment toolkit for OpenClaw Gateway** - Automated installation, configuration, and management.

## 🎯 Features

- **True One-Click Deployment** - All configurations done correctly from the start
- **No Manual Fixes Required** - Deploy once, use immediately
- **Intelligent Troubleshooting** - Automatic problem detection and diagnosis
- **Complete Documentation** - From quick start to in-depth analysis
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
- ✅ Install all dependencies
- ✅ Configure OpenClaw Gateway
- ✅ Set up Nginx reverse proxy with correct WebSocket paths
- ✅ Configure Tailscale routing (if selected)
- ✅ Set up Gateway allowedOrigins automatically
- ✅ Create systemd service for auto-start
- ✅ Verify everything works

## 📦 What's Included

### Core Scripts
- **openclaw-deploy.sh** - One-click deployment script (all you need!)
- **openclaw-troubleshoot.sh** - Diagnostic and troubleshooting tool

### Maintenance Tools (Optional)
Located in `tools/` directory - only needed for existing installations or manual fixes:
- `fix-tailscale-routing.sh` - Fix Tailscale routing (for old installations)
- `fix-gateway-origin.sh` - Fix Gateway origin (for manual configurations)
- `reset-gateway-token.sh` - Reset authentication token (if needed)

**New users don't need these tools** - the deployment script handles everything correctly.

### Documentation
- `README.md` - This file (English)
- `README_CN.md` - Chinese version
- `DEPLOYMENT_SUMMARY.md` - Architecture and best practices
- `POST_DEPLOYMENT_ISSUES.md` - Historical issues and solutions
- `FINAL_REPORT.md` - Complete project summary
- `CHANGELOG.md` - Version history
- `QUICK_REFERENCE.txt` - Quick reference card
- `INDEX.txt` - Toolkit index

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

## 📚 Documentation

- **Quick Start**: Just run `bash openclaw-deploy.sh`
- **Troubleshooting**: Run `bash openclaw-troubleshoot.sh` if you encounter issues
- **Architecture Details**: See [DEPLOYMENT_SUMMARY.md](DEPLOYMENT_SUMMARY.md)
- **Maintenance Tools**: See [tools/README.md](tools/README.md) (for existing installations)

## 🎓 Built-in Best Practices

The deployment script automatically implements:
- ✅ **WebSocket Reverse Proxy** - Unified path prefix design
- ✅ **API Key Management** - Environment variable approach
- ✅ **Tailscale Configuration** - All traffic through Nginx with correct routing
- ✅ **Gateway Security** - Token authentication and origin whitelist
- ✅ **Service Management** - Systemd integration for reliability

## 📊 Statistics

- **Total Files**: 15+
- **One Command**: `bash openclaw-deploy.sh`
- **Zero Manual Fixes**: Everything configured correctly from the start

## 📞 Support

- **Official Docs**: https://docs.openclaw.ai/
- **Troubleshooting**: https://docs.openclaw.ai/troubleshooting
- **Issues**: https://github.com/t2krew/openclaw-toolkit/issues

## 📝 License

MIT License

## 🙏 Acknowledgments

Developed during the deployment of OpenClaw Gateway on Raspberry Pi (ARM64).

---

**Version**: v1.2.0
**Last Updated**: 2026-03-06
**Repository**: https://github.com/t2krew/openclaw-toolkit
