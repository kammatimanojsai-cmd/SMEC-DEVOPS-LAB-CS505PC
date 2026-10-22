@echo off
REM Starts RUN-ALL.ps1 in an Administrator PowerShell window (Windows asks for permission).
powershell -NoProfile -Command "Start-Process powershell -Verb RunAs -ArgumentList '-NoExit -NoProfile -ExecutionPolicy Bypass -File ""%~dp0RUN-ALL.ps1""'"
