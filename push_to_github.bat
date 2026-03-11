@echo off
REM push_to_github.bat - 自动推送所有更改到GitHub
REM 使用方法: 双击运行此批处理文件

echo.
echo ========================================
echo   推送到GitHub
echo ========================================
echo.

cd /d "C:\Users\windows\Desktop\leo-bh-scheduling"

echo [1/3] 检查状态...
git status --short

echo.
echo [2/3] 尝试推送...
git push origin main

if %errorlevel% equ 0 (
    echo.
    echo ========================================
    echo   推送成功！
    echo ========================================
    echo.
    echo 访问: https://github.com/yuanhaobupt/leo-bh-scheduling
    echo.
    
    echo [3/3] 创建Release...
    echo.
    echo 请在GitHub网页上创建Release:
    echo 1. 访问: https://github.com/yuanhaobupt/leo-bh-scheduling/releases
    echo 2. 点击 "Create a new release"
    echo 3. Tag: v1.1.0
    echo 4. 复制 RELEASE_v1.1.0_TEMPLATE.md 的内容
    echo.
) else (
    echo.
    echo ========================================
    echo   推送失败
    echo ========================================
    echo.
    echo 可能的原因:
    echo 1. 网络连接问题 - 请检查网络
    echo 2. 需要代理 - 运行 push_with_proxy.bat
    echo 3. 认证问题 - 检查GitHub登录状态
    echo.
    echo 稍后重试或使用代理
    echo.
)

pause
