@echo off
echo ============================================
echo  PROGRAMAS AL INICIO (STARTUP)
echo ============================================
echo.
echo [HKCU Run]
reg query "HKCU\Software\Microsoft\Windows\CurrentVersion\Run" 2>nul
echo.
echo [HKLM Run]
reg query "HKLM\Software\Microsoft\Windows\CurrentVersion\Run" 2>nul
echo.
echo [Carpeta Startup usuario]
dir "%APPDATA%\Microsoft\Windows\Start Menu\Programs\Startup" 2>nul
echo.
echo [Tareas programadas activas (Task Scheduler)]
schtasks /query /fo LIST /v 2>nul | findstr /i "Task Name: Status: Run As"
echo.
