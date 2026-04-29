@echo off
setlocal
set FILE=%~dp0NeedleSimulatorWeb.html
if not exist "%FILE%" (
  echo NeedleSimulatorWeb.html not found: "%FILE%"
  pause
  exit /b 1
)
start "" "%FILE%"
endlocal
