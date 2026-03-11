@echo off
REM push_with_proxy.bat - 使用代理推送到GitHub
REM 使用方法: 双击运行此批处理文件
REM 注意: 请根据您的代理软件修改端口号

echo.
echo ========================================
echo   使用代理推送到GitHub
echo ========================================
echo.

REM 设置代理 (请根据您的代理软件调整端口)
set HTTP_PROXY=http://127.0.0.1:7890
set HTTPS_PROXY=http://127.0.0.1:7890

echo 已设置代理: http://127.0.0.1:7890
echo.
echo 如果您的代理端口不是7890，请:
echo 1. 关闭此窗口
echo 2. 编辑 push_with_proxy.bat
echo 3. 修改端口号
echo 4. 重新运行
echo.
pause

cd /d "C:\Users\windows\Desktop\leo-bh-scheduling"

echo 正在推送...
echo.

git push origin main

if %errorlevel% equ 0 (
    echo.
    echo ========================================
    echo   推送成功！
    echo ========================================
    echo.
    echo 访问您的仓库:
    echo https://github.com/yuanhaobupt/leo-bh-scheduling
    echo.
    echo 下一步:
    echo 1. 创建 Release v1.1.0
    echo 2. 更新论文中的代码链接
    echo 3. 通知用户更新
    echo.
) else (
    echo.
    echo ========================================
    echo   推送失败
    echo ========================================
    echo.
    echo 可能的原因:
    echo 1. 代理未启动或端口错误
    echo 2. 网络连接问题
    echo 3. GitHub认证问题
    echo.
    echo 请尝试:
    echo 1. 检查代理软件是否运行
    echo 2. 确认代理端口号
    echo 3. 检查GitHub登录状态
    echo.
)

REM 清除代理设置
set HTTP_PROXY=
set HTTPS_PROXY=

pause
