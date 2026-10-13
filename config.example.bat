@echo off
REM ============================================================
REM  OllaBox 本地配置模板
REM  用法：把本文件复制为 config.bat，按需取消注释并改成你的实际路径。
REM  config.bat 不会被提交到版本库（已在 .gitignore 中忽略）。
REM ============================================================

REM ---- Ollama 可执行文件 ----
REM 若 ollama 已加入 PATH，可保持默认（不设置）。否则填可执行文件的完整路径：
REM set "OLLA_CMD=C:/path/to/ollama.exe"

REM ---- Ollama 模型目录（仅当你没有设置系统环境变量 OLLAMA_MODELS 时需要）----
REM set "OLLAMA_MODELS=D:/Ollama/models"

REM ---- Python 解释器（仅当 python 不在 PATH 时设置）----
REM set "PY=C:/path/to/python.exe"

REM ---- 网页服务端口（默认 8788）----
REM set "PORT=8788"
