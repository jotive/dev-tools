@echo off
echo ============================================
echo  DEV ENVIRONMENT CHECK
echo ============================================
echo.

echo [Node / npm]
node --version 2>nul || echo NOT FOUND
npm --version 2>nul || echo NOT FOUND

echo.
echo [Python]
python --version 2>nul || echo NOT FOUND
pip --version 2>nul || echo NOT FOUND

echo.
echo [Git]
git --version 2>nul || echo NOT FOUND

echo.
echo [Docker]
docker --version 2>nul || echo NOT FOUND
docker compose version 2>nul || echo NOT FOUND

echo.
echo [WSL]
wsl --list --verbose 2>nul || echo NOT FOUND

echo.
echo [VS Code]
code --version 2>nul || echo NOT FOUND

echo.
echo [Bun]
bun --version 2>nul || echo NOT FOUND

echo.
echo [PowerShell]
powershell -Command "$PSVersionTable.PSVersion"

echo.
