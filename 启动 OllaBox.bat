@echo off
title OllaBox 启动器
setlocal

REM ============================================================
REM  OllaBox 启动器（可移植版）
REM  前置：本机已安装 Ollama，且 Ollama 能找到模型
REM  可选：同目录 config.bat 覆盖默认命令（模板见 config.example.bat）
REM ============================================================

set "DIR=%~dp0"
if "%DIR:~-1%"=="\" set "DIR=%DIR:~0,-1%"

REM ---- 载入本地配置（该文件不入版本库）----
if exist "%DIR%\config.bat" call "%DIR%\config.bat"

REM ---- 默认值（可被 config.bat 或系统环境变量覆盖）----
if not defined OLLAMA_HOST    set "OLLAMA_HOST=127.0.0.1:11434"
if not defined OLLAMA_ORIGINS set "OLLAMA_ORIGINS=*"
if not defined OLLA_CMD       set "OLLA_CMD=ollama"
if not defined PY             set "PY=python"
if not defined PORT           set "PORT=8788"

set "PROFILE=%DIR%\browser-profile"
set "EDGE=C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe"
set "CHROME=C:\Program Files\Google\Chrome\Application\chrome.exe"

echo ============================================================
echo   OllaBox - 本地模型工作台  一键启动
echo ============================================================
echo.

REM ---- 0) 自检 ----
if not exist "%DIR%\index.html" (
  echo [错误] 找不到网页主程序: %DIR%\index.html
  echo        请把 index.html 放回 OllaBox 目录后再运行本脚本。
  echo.
  pause
  exit /b 1
)

REM ---- 1) Ollama 服务 ----
netstat -ano | findstr ":11434" | findstr "LISTENING" >nul 2>&1
if errorlevel 1 (
  echo [1/3] Ollama 服务未运行，正在启动...
  "%OLLA_CMD%" --version >nul 2>&1
  if errorlevel 1 (
    echo     [错误] 未找到 ollama 命令。
    echo            请先安装 Ollama，或在 config.bat 里把 OLLA_CMD 设为 ollama.exe 的完整路径。
    echo.
    pause
    exit /b 1
  )
  start "Ollama 服务 (勿关)" /min "%OLLA_CMD%" serve
  ping -n 6 127.0.0.1 >nul
) else (
  echo [1/3] Ollama 服务已在运行，跳过。
)

REM ---- 2) 网页服务 ----
"%PY%" --version >nul 2>&1
if errorlevel 1 (
  echo     [错误] 未找到 Python。
  echo            请安装 Python 并加入 PATH，或在 config.bat 里把 PY 设为 python.exe 的完整路径。
  echo            也可以改用「启动 OllaBox (直开网页).bat」，它不需要 Python。
  echo.
  pause
  exit /b 1
)
echo [2/3] 启动网页服务 (端口 %PORT%)...
start "OllaBox 网页服务 (勿关)" /min "%PY%" -m http.server %PORT% --bind 127.0.0.1 --directory "%DIR%"

set "READY="
for /l %%i in (1,1,15) do if not defined READY call :waitport
if not defined READY (
  echo     [错误] 端口 %PORT% 未在 15 秒内就绪，可能有其他程序占用。
  echo            若页面打不开，可关掉刚弹出的黑窗口，改用「直开网页」方式。
)

REM ---- 3) 用独立配置打开页面（数据落在本目录，不污染日常浏览器）----
if not exist "%PROFILE%" mkdir "%PROFILE%"
echo [3/3] 打开页面（独立配置：%PROFILE%）...

if exist "%EDGE%" goto :use_edge
if exist "%CHROME%" goto :use_chrome

echo     未找到 Edge / Chrome，改用系统默认浏览器（数据会落到系统浏览器配置目录）。
start "" "http://127.0.0.1:%PORT%/"
goto :done

:use_edge
start "" "%EDGE%" --user-data-dir="%PROFILE%" --no-first-run --no-default-browser-check "http://127.0.0.1:%PORT%/"
goto :done

:use_chrome
start "" "%CHROME%" --user-data-dir="%PROFILE%" --no-first-run --no-default-browser-check "http://127.0.0.1:%PORT%/"
goto :done

:done
echo.
echo 完成。会话记录与知识库保存在：
echo       %PROFILE%
echo 请保留两个最小化窗口（Ollama 服务 / 网页服务），关掉即停服务。
echo 只关闭网页服务可运行「停止 OllaBox.bat」。
echo.
ping -n 9 127.0.0.1 >nul
exit /b 0

:waitport
netstat -ano | findstr ":%PORT%" | findstr "LISTENING" >nul 2>&1
if not errorlevel 1 set "READY=1"
if not defined READY ping -n 2 127.0.0.1 >nul
goto :eof
