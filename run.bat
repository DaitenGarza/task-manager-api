@echo off
setlocal
title Task Manager API
cd /d "%~dp0"

echo.
echo  ========================================================
echo   Task Manager API  ^|  FastAPI + SQLite
echo  ========================================================
echo   First run installs Python (if needed) and packages.
echo   Later runs start in a few seconds.
echo.

powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0run.ps1"

if errorlevel 1 (
  echo.
  echo Task Manager API could not start. Review the message above.
) else (
  echo.
  echo Task Manager API stopped.
)
pause
