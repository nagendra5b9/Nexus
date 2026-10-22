@echo off
setlocal
cd /d "%~dp0frontend"
if not exist "package.json" (
  echo ERROR: frontend\package.json was not found.
  echo Keep this script in the root of the extracted project folder, alongside pom.xml and frontend/.
  pause
  exit /b 1
)
where node >nul 2>nul
if errorlevel 1 (
  echo ERROR: Node.js is not installed or is not on PATH.
  echo Install Node.js 22.12 or newer, then reopen this window.
  pause
  exit /b 1
)
echo.
echo Nexus Commerce Cloud - Design 01: Electric Cyber-Pop + Obsidian Glass
node --version
call npm.cmd --version
if errorlevel 1 (
  echo ERROR: npm is not available. Verify the Node.js installation.
  pause
  exit /b 1
)
if not exist "node_modules" (
  echo.
  echo First run: installing frontend dependencies. Internet is required for this step.
  call npm.cmd install
  if errorlevel 1 (
    echo.
    echo INSTALL FAILED. Check the network or npm error above, then rerun this file.
    pause
    exit /b 1
  )
)
echo.
echo Starting the frontend. Keep this window open.
echo Open the Local URL printed below, normally http://localhost:5173/
echo.
call npm.cmd run dev
pause
