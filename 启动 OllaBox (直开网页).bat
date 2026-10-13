@echo off
title OllaBox 启动器（直开网页模式）
setlocal

REM ============================================================
REM  OllaBox 直开网页模式：不起网页服务，直接用浏览器打开 index.html
REM  数据（会话 / 知识库）保存在本目录 browser-profile，不污染日常浏览器
REM ============================================================

set "DIR=%~dp0"
if "%DIR:~-1%"=="\" set "DIR=%DIR:~0,-1%"

REM ---- 载入本地配置（该文件不入版本库）----
if exist "%DIR%\config.bat" call "%DIR%\config.bat"

if not defined OLLAMA_HOST    set "OLLAMA_HOST=127.0.0.1:11434"
if not defined OLLAMA_ORIGINS set "OLLAMA_ORIGINS=*"
if not defined OLLA_CMD       set "OLLA_CMD=ollama"

set "PROFILE=%DIR%\browser-profile"
set "EDGE=C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe"
set "CHROME=C:\Program Files\Google\Chrome\Application\chrome.exe"
set "PAGE=file:///%DIR:\=/%/index.html"

echo ============================================================
echo   OllaBox - 直开网页模式（不需要网页服务）
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
  echo [1/2] Ollama 服务未运行，正在启动...
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
  echo [1/2] Ollama 服务已在运行，跳过。
)

REM ---- 2) 用独立配置打开页面 ----
if not exist "%PROFILE%" mkdir "%PROFILE%"
echo [2/2] 打开页面：
echo       %PAGE%

if exist "%EDGE%" goto :use_edge
if exist "%CHROME%" goto :use_chrome

echo     未找到 Edge / Chrome，改用系统默认浏览器（数据会落到系统浏览器配置目录）。
start "" "%PAGE%"
goto :done

:use_edge
start "" "%EDGE%" --user-data-dir="%PROFILE%" --no-first-run --no-default-browser-check "%PAGE%"
goto :done

:use_chrome
start "" "%CHROME%" --user-data-dir="%PROFILE%" --no-first-run --no-default-browser-check "%PAGE%"
goto :done

:done
echo.
echo 完成。会话记录与知识库保存在：
echo       %PROFILE%
echo 提示：直接双击 index.html 会用系统默认浏览器配置打开，数据会落到系统目录。
echo       想固定数据位置，请始终用本脚本。
echo.
ping -n 9 127.0.0.1 >nul
exit /b 0
