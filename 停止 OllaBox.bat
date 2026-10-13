@echo off
title 停止 OllaBox 网页服务
setlocal

set "DIR=%~dp0"
if "%DIR:~-1%"=="\" set "DIR=%DIR:~0,-1%"
if exist "%DIR%\config.bat" call "%DIR%\config.bat"
if not defined PORT set "PORT=8788"

echo 正在停止 OllaBox 网页服务 (端口 %PORT%)...
set "FOUND="
for /f "tokens=5" %%a in ('netstat -ano ^| findstr ":%PORT%" ^| findstr LISTENING') do (
  taskkill /F /PID %%a >nul 2>&1
  set "FOUND=1"
)
if defined FOUND (
  echo 已停止。
) else (
  echo 网页服务本来就没在运行。
)
echo 注意：Ollama 服务未受影响；如需停止，关闭其窗口或运行 taskkill /F /IM ollama.exe
ping -n 4 127.0.0.1 >nul
