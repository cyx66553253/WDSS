@echo off
setlocal
cd /d "%~dp0"
start "" /min powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0local-server.ps1"
timeout /t 1 /nobreak >nul
start "" "http://localhost:8080/"
