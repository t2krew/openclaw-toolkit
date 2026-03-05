# OpenClaw WSL2 快速安装脚本
# 版本: 2.2.0
# 适用于: Windows 10/11

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "OpenClaw WSL2 快速安装向导" -ForegroundColor Cyan
Write-Host "版本: 2.2.0" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# 检查管理员权限
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

if (-not $isAdmin) {
    Write-Host "错误: 需要管理员权限运行此脚本" -ForegroundColor Red
    Write-Host "请右键点击 PowerShell，选择 '以管理员身份运行'" -ForegroundColor Yellow
    Write-Host ""
    Read-Host "按回车键退出"
    exit 1
}

Write-Host "✓ 管理员权限检查通过" -ForegroundColor Green
Write-Host ""

# 检查 Windows 版本
$osVersion = [System.Environment]::OSVersion.Version
$buildNumber = $osVersion.Build

Write-Host "检测到 Windows 版本: $($osVersion.Major).$($osVersion.Minor) (Build $buildNumber)" -ForegroundColor Cyan

if ($buildNumber -lt 19041) {
    Write-Host "错误: WSL2 需要 Windows 10 版本 2004 (Build 19041) 或更高版本" -ForegroundColor Red
    Write-Host "当前版本: Build $buildNumber" -ForegroundColor Yellow
    Write-Host "请更新 Windows 后再试" -ForegroundColor Yellow
    Write-Host ""
    Read-Host "按回车键退出"
    exit 1
}

Write-Host "✓ Windows 版本检查通过" -ForegroundColor Green
Write-Host ""

# 检查 WSL 是否已安装
Write-Host "检查 WSL 安装状态..." -ForegroundColor Cyan

$wslInstalled = $false
try {
    $wslVersion = wsl --version 2>$null
    if ($LASTEXITCODE -eq 0) {
        $wslInstalled = $true
        Write-Host "✓ WSL 已安装" -ForegroundColor Green
    }
} catch {
    Write-Host "WSL 未安装" -ForegroundColor Yellow
}

Write-Host ""

# 如果 WSL 未安装，询问是否安装
if (-not $wslInstalled) {
    Write-Host "WSL2 未安装。是否现在安装？(Y/N)" -ForegroundColor Yellow
    $install = Read-Host ">"

    if ($install -eq "Y" -or $install -eq "y") {
        Write-Host ""
        Write-Host "正在安装 WSL2..." -ForegroundColor Cyan
        Write-Host "这可能需要几分钟时间..." -ForegroundColor Yellow
        Write-Host ""

        try {
            wsl --install

            if ($LASTEXITCODE -eq 0) {
                Write-Host ""
                Write-Host "✓ WSL2 安装成功！" -ForegroundColor Green
                Write-Host ""
                Write-Host "重要提示:" -ForegroundColor Yellow
                Write-Host "1. 需要重启计算机才能完成安装" -ForegroundColor Yellow
                Write-Host "2. 重启后，Ubuntu 会自动启动" -ForegroundColor Yellow
                Write-Host "3. 按提示创建用户名和密码" -ForegroundColor Yellow
                Write-Host "4. 然后运行以下命令部署 OpenClaw:" -ForegroundColor Yellow
                Write-Host ""
                Write-Host "   git clone https://github.com/t2krew/openclaw-toolkit.git" -ForegroundColor Cyan
                Write-Host "   cd openclaw-toolkit" -ForegroundColor Cyan
                Write-Host "   sudo bash openclaw-deploy.sh" -ForegroundColor Cyan
                Write-Host ""
                Write-Host "是否现在重启计算机？(Y/N)" -ForegroundColor Yellow
                $restart = Read-Host ">"

                if ($restart -eq "Y" -or $restart -eq "y") {
                    Write-Host "正在重启..." -ForegroundColor Cyan
                    Restart-Computer
                } else {
                    Write-Host "请手动重启计算机以完成安装" -ForegroundColor Yellow
                }
            } else {
                Write-Host "✗ WSL2 安装失败" -ForegroundColor Red
                Write-Host "请查看错误信息并手动安装" -ForegroundColor Yellow
            }
        } catch {
            Write-Host "✗ 安装过程出错: $_" -ForegroundColor Red
        }
    } else {
        Write-Host "已取消安装" -ForegroundColor Yellow
    }

    Write-Host ""
    Read-Host "按回车键退出"
    exit 0
}

# WSL 已安装，检查 Ubuntu
Write-Host "检查 Ubuntu 安装状态..." -ForegroundColor Cyan

$ubuntuInstalled = $false
try {
    $wslList = wsl --list --quiet
    if ($wslList -match "Ubuntu") {
        $ubuntuInstalled = $true
        Write-Host "✓ Ubuntu 已安装" -ForegroundColor Green
    }
} catch {
    Write-Host "无法检查 Ubuntu 状态" -ForegroundColor Yellow
}

Write-Host ""

# 如果 Ubuntu 未安装，询问是否安装
if (-not $ubuntuInstalled) {
    Write-Host "Ubuntu 未安装。是否现在安装？(Y/N)" -ForegroundColor Yellow
    $install = Read-Host ">"

    if ($install -eq "Y" -or $install -eq "y") {
        Write-Host ""
        Write-Host "正在安装 Ubuntu..." -ForegroundColor Cyan

        try {
            wsl --install -d Ubuntu

            if ($LASTEXITCODE -eq 0) {
                Write-Host ""
                Write-Host "✓ Ubuntu 安装成功！" -ForegroundColor Green
                Write-Host ""
                Write-Host "下一步:" -ForegroundColor Yellow
                Write-Host "1. Ubuntu 会自动启动" -ForegroundColor Yellow
                Write-Host "2. 按提示创建用户名和密码" -ForegroundColor Yellow
                Write-Host "3. 运行以下命令部署 OpenClaw:" -ForegroundColor Yellow
                Write-Host ""
                Write-Host "   git clone https://github.com/t2krew/openclaw-toolkit.git" -ForegroundColor Cyan
                Write-Host "   cd openclaw-toolkit" -ForegroundColor Cyan
                Write-Host "   sudo bash openclaw-deploy.sh" -ForegroundColor Cyan
                Write-Host ""
            } else {
                Write-Host "✗ Ubuntu 安装失败" -ForegroundColor Red
            }
        } catch {
            Write-Host "✗ 安装过程出错: $_" -ForegroundColor Red
        }
    } else {
        Write-Host "已取消安装" -ForegroundColor Yellow
    }

    Write-Host ""
    Read-Host "按回车键退出"
    exit 0
}

# Ubuntu 已安装，提供快速部署选项
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Ubuntu 已就绪！" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "选择操作:" -ForegroundColor Yellow
Write-Host "1. 启动 Ubuntu 并部署 OpenClaw" -ForegroundColor Cyan
Write-Host "2. 仅启动 Ubuntu" -ForegroundColor Cyan
Write-Host "3. 查看 WSL 状态" -ForegroundColor Cyan
Write-Host "4. 退出" -ForegroundColor Cyan
Write-Host ""
$choice = Read-Host "请选择 (1-4)"

switch ($choice) {
    "1" {
        Write-Host ""
        Write-Host "正在启动 Ubuntu 并准备部署..." -ForegroundColor Cyan
        Write-Host ""
        Write-Host "将执行以下命令:" -ForegroundColor Yellow
        Write-Host "  git clone https://github.com/t2krew/openclaw-toolkit.git" -ForegroundColor Cyan
        Write-Host "  cd openclaw-toolkit" -ForegroundColor Cyan
        Write-Host "  sudo bash openclaw-deploy.sh" -ForegroundColor Cyan
        Write-Host ""

        # 启动 WSL 并执行命令
        wsl -d Ubuntu bash -c "cd ~ && git clone https://github.com/t2krew/openclaw-toolkit.git 2>/dev/null || (cd openclaw-toolkit && git pull); cd openclaw-toolkit && sudo bash openclaw-deploy.sh"
    }
    "2" {
        Write-Host ""
        Write-Host "正在启动 Ubuntu..." -ForegroundColor Cyan
        wsl -d Ubuntu
    }
    "3" {
        Write-Host ""
        Write-Host "WSL 状态:" -ForegroundColor Cyan
        wsl --list --verbose
        Write-Host ""
        Read-Host "按回车键继续"
    }
    "4" {
        Write-Host "再见！" -ForegroundColor Cyan
        exit 0
    }
    default {
        Write-Host "无效选择" -ForegroundColor Red
    }
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "完成！" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "访问 OpenClaw Control UI:" -ForegroundColor Yellow
Write-Host "  http://localhost:9000/openclaw/" -ForegroundColor Cyan
Write-Host ""
Write-Host "常用命令:" -ForegroundColor Yellow
Write-Host "  启动 WSL: wsl" -ForegroundColor Cyan
Write-Host "  停止 WSL: wsl --shutdown" -ForegroundColor Cyan
Write-Host "  查看状态: wsl --list --verbose" -ForegroundColor Cyan
Write-Host ""
Write-Host "详细文档: WINDOWS_WSL2_GUIDE.md" -ForegroundColor Yellow
Write-Host ""
Read-Host "按回车键退出"
