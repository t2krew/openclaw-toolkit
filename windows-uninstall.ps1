# OpenClaw Windows WSL2 卸载脚本
# 版本: 2.5.0
# 日期: 2026-03-06

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "OpenClaw Windows WSL2 卸载向导" -ForegroundColor Cyan
Write-Host "版本: 2.5.0" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# 检查管理员权限
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

if (-not $isAdmin) {
    Write-Host "警告: 某些操作需要管理员权限" -ForegroundColor Yellow
    Write-Host "建议右键点击 PowerShell，选择 '以管理员身份运行'" -ForegroundColor Yellow
    Write-Host ""
}

# 确认卸载
Write-Host "此操作将卸载 OpenClaw 及其在 WSL2 中的所有配置" -ForegroundColor Yellow
Write-Host ""
$confirm = Read-Host "是否继续？(yes/no)"

if ($confirm -ne "yes") {
    Write-Host "已取消卸载" -ForegroundColor Cyan
    exit 0
}

Write-Host ""
Write-Host "开始卸载..." -ForegroundColor Cyan
Write-Host ""

# 检查 WSL2 是否安装
Write-Host "[1/6] 检查 WSL2 状态..." -ForegroundColor Cyan

try {
    $wslVersion = wsl --version 2>$null
    if ($LASTEXITCODE -ne 0) {
        Write-Host "✗ WSL2 未安装或未运行" -ForegroundColor Red
        Write-Host ""
        Write-Host "如果 OpenClaw 安装在 WSL2 中，请先启动 WSL2" -ForegroundColor Yellow
        Write-Host ""
        $continueAnyway = Read-Host "是否继续卸载 Windows 组件？(yes/no)"
        if ($continueAnyway -ne "yes") {
            exit 0
        }
    } else {
        Write-Host "✓ WSL2 已安装" -ForegroundColor Green
    }
} catch {
    Write-Host "✗ 无法检查 WSL2 状态" -ForegroundColor Red
}

Write-Host ""

# 检查 Ubuntu 是否安装
Write-Host "[2/6] 检查 Ubuntu 状态..." -ForegroundColor Cyan

try {
    $wslList = wsl --list --quiet
    if ($wslList -match "Ubuntu") {
        Write-Host "✓ Ubuntu 已安装" -ForegroundColor Green
        $hasUbuntu = $true
    } else {
        Write-Host "✗ Ubuntu 未安装" -ForegroundColor Yellow
        $hasUbuntu = $false
    }
} catch {
    Write-Host "✗ 无法检查 Ubuntu 状态" -ForegroundColor Red
    $hasUbuntu = $false
}

Write-Host ""

# 在 WSL2 中卸载 OpenClaw
if ($hasUbuntu) {
    Write-Host "[3/6] 在 WSL2 Ubuntu 中卸载 OpenClaw..." -ForegroundColor Cyan
    Write-Host ""

    # 检查是否存在卸载脚本
    $hasUninstallScript = wsl -d Ubuntu bash -c "test -f ~/openclaw-toolkit/openclaw-uninstall.sh && echo 'yes' || echo 'no'"

    if ($hasUninstallScript -eq "yes") {
        Write-Host "找到卸载脚本，开始执行..." -ForegroundColor Cyan
        Write-Host ""

        # 运行卸载脚本
        wsl -d Ubuntu bash -c "cd ~/openclaw-toolkit && bash openclaw-uninstall.sh"

        Write-Host ""
        Write-Host "✓ WSL2 中的 OpenClaw 已卸载" -ForegroundColor Green
    } else {
        Write-Host "未找到卸载脚本，尝试手动卸载..." -ForegroundColor Yellow
        Write-Host ""

        # 手动卸载
        Write-Host "停止服务..." -ForegroundColor Cyan
        wsl -d Ubuntu bash -c "sudo systemctl stop openclaw-gateway.service 2>/dev/null || true"
        wsl -d Ubuntu bash -c "sudo systemctl disable openclaw-gateway.service 2>/dev/null || true"

        Write-Host "删除服务文件..." -ForegroundColor Cyan
        wsl -d Ubuntu bash -c "sudo rm -f /etc/systemd/system/openclaw-gateway.service 2>/dev/null || true"
        wsl -d Ubuntu bash -c "sudo systemctl daemon-reload 2>/dev/null || true"

        Write-Host "清理 Nginx 配置..." -ForegroundColor Cyan
        wsl -d Ubuntu bash -c "sudo rm -f /etc/nginx/sites-available/openclaw-gateway.conf 2>/dev/null || true"
        wsl -d Ubuntu bash -c "sudo rm -f /etc/nginx/sites-enabled/openclaw-gateway.conf 2>/dev/null || true"
        wsl -d Ubuntu bash -c "sudo rm -f /etc/nginx/conf.d/openclaw-gateway.conf 2>/dev/null || true"

        Write-Host "卸载 OpenClaw..." -ForegroundColor Cyan
        wsl -d Ubuntu bash -c "npm uninstall -g openclaw 2>/dev/null || true"

        Write-Host ""
        Write-Host "✓ 手动卸载完成" -ForegroundColor Green
    }
} else {
    Write-Host "[3/6] 跳过 WSL2 卸载（Ubuntu 未安装）" -ForegroundColor Yellow
}

Write-Host ""

# 删除配置和数据
Write-Host "[4/6] 删除配置和数据..." -ForegroundColor Cyan
Write-Host ""

if ($hasUbuntu) {
    Write-Host "是否删除 WSL2 中的 OpenClaw 配置和数据？" -ForegroundColor Yellow
    Write-Host "  - 配置文件: ~/.openclaw/" -ForegroundColor Gray
    Write-Host "  - 数据文件: ~/.local/share/openclaw/" -ForegroundColor Gray
    Write-Host "  - 项目目录: ~/openclaw-toolkit/" -ForegroundColor Gray
    Write-Host ""
    $deleteData = Read-Host "删除配置和数据？(yes/no)"

    if ($deleteData -eq "yes") {
        Write-Host "删除中..." -ForegroundColor Cyan
        wsl -d Ubuntu bash -c "rm -rf ~/.openclaw 2>/dev/null || true"
        wsl -d Ubuntu bash -c "rm -rf ~/.local/share/openclaw 2>/dev/null || true"
        wsl -d Ubuntu bash -c "rm -rf ~/openclaw-toolkit 2>/dev/null || true"
        Write-Host "✓ 配置和数据已删除" -ForegroundColor Green
    } else {
        Write-Host "✓ 保留配置和数据" -ForegroundColor Cyan
    }
} else {
    Write-Host "✓ 跳过（Ubuntu 未安装）" -ForegroundColor Yellow
}

Write-Host ""

# 卸载 WSL2 和 Ubuntu
Write-Host "[5/6] 卸载 WSL2 和 Ubuntu..." -ForegroundColor Cyan
Write-Host ""

Write-Host "是否卸载 WSL2 和 Ubuntu？" -ForegroundColor Yellow
Write-Host "警告: 这将删除 Ubuntu 中的所有数据！" -ForegroundColor Red
Write-Host ""
$uninstallWSL = Read-Host "卸载 WSL2 和 Ubuntu？(yes/no)"

if ($uninstallWSL -eq "yes") {
    if ($hasUbuntu) {
        Write-Host "卸载 Ubuntu..." -ForegroundColor Cyan
        wsl --unregister Ubuntu

        if ($LASTEXITCODE -eq 0) {
            Write-Host "✓ Ubuntu 已卸载" -ForegroundColor Green
        } else {
            Write-Host "✗ Ubuntu 卸载失败" -ForegroundColor Red
        }
    }

    Write-Host ""
    Write-Host "是否禁用 WSL 功能？" -ForegroundColor Yellow
    Write-Host "注意: 这需要管理员权限并重启计算机" -ForegroundColor Yellow
    Write-Host ""
    $disableWSL = Read-Host "禁用 WSL？(yes/no)"

    if ($disableWSL -eq "yes") {
        if ($isAdmin) {
            Write-Host "禁用 WSL..." -ForegroundColor Cyan
            dism.exe /online /disable-feature /featurename:Microsoft-Windows-Subsystem-Linux /norestart
            dism.exe /online /disable-feature /featurename:VirtualMachinePlatform /norestart

            Write-Host "✓ WSL 功能已禁用" -ForegroundColor Green
            Write-Host ""
            Write-Host "需要重启计算机才能完成卸载" -ForegroundColor Yellow
            Write-Host ""
            $restart = Read-Host "是否现在重启？(yes/no)"

            if ($restart -eq "yes") {
                Write-Host "正在重启..." -ForegroundColor Cyan
                Restart-Computer
            } else {
                Write-Host "请手动重启计算机以完成卸载" -ForegroundColor Yellow
            }
        } else {
            Write-Host "✗ 需要管理员权限才能禁用 WSL" -ForegroundColor Red
            Write-Host "请以管理员身份运行此脚本" -ForegroundColor Yellow
        }
    } else {
        Write-Host "✓ 保留 WSL 功能" -ForegroundColor Cyan
    }
} else {
    Write-Host "✓ 保留 WSL2 和 Ubuntu" -ForegroundColor Cyan
}

Write-Host ""

# 生成卸载报告
Write-Host "[6/6] 生成卸载报告..." -ForegroundColor Cyan

$reportPath = "$PSScriptRoot\windows-uninstall-report.txt"

$reportContent = @"
OpenClaw Windows WSL2 卸载报告
==============================

卸载时间: $(Get-Date -Format "yyyy-MM-dd HH:mm:ss")
操作系统: Windows $(([System.Environment]::OSVersion.Version).Major).$(([System.Environment]::OSVersion.Version).Minor)
管理员权限: $isAdmin

已执行的操作:
- 检查 WSL2 状态
- 检查 Ubuntu 状态
- 在 WSL2 中卸载 OpenClaw
- 删除配置和数据（如果选择）
- 卸载 WSL2 和 Ubuntu（如果选择）

保留的内容:
- WSL2 功能（如果选择保留）
- Ubuntu 发行版（如果选择保留）
- 配置和数据（如果选择保留）

如需重新安装:

方法 1: 使用 WSL2 快速安装脚本
  iwr -useb https://raw.githubusercontent.com/t2krew/openclaw-toolkit/main/install-wsl2.ps1 | iex

方法 2: 手动安装
  1. 安装 WSL2:
     wsl --install

  2. 重启计算机

  3. 在 Ubuntu 中安装 OpenClaw:
     git clone https://github.com/t2krew/openclaw-toolkit.git
     cd openclaw-toolkit
     sudo bash openclaw-deploy.sh

方法 3: 使用 Docker（推荐）
  1. 安装 Docker Desktop for Windows
  2. 克隆仓库并运行:
     git clone https://github.com/t2krew/openclaw-toolkit.git
     cd openclaw-toolkit
     docker-compose up -d

更多信息:
- GitHub: https://github.com/t2krew/openclaw-toolkit
- WSL2 指南: WINDOWS_WSL2_GUIDE.md
- Docker 指南: DOCKER_GUIDE.md

"@

$reportContent | Out-File -FilePath $reportPath -Encoding UTF8

Write-Host "✓ 卸载报告已保存到: $reportPath" -ForegroundColor Green

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "OpenClaw 卸载完成！" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "卸载报告: $reportPath" -ForegroundColor Cyan
Write-Host ""
Write-Host "如需重新安装，请参考卸载报告中的说明" -ForegroundColor Cyan
Write-Host ""
Write-Host "感谢使用 OpenClaw Toolkit！" -ForegroundColor Cyan
Write-Host ""

Read-Host "按回车键退出"
