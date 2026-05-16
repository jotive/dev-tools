@echo off
set /p PORT="Puerto a matar: "
echo.
echo Buscando proceso en puerto %PORT%...
for /f "tokens=5" %%p in ('netstat -ano ^| findstr ":%PORT% "') do (
    echo PID: %%p
    tasklist /FI "PID eq %%p" 2>nul | findstr /v "INFO"
    set /p KILL="Matar PID %%p? (s/N): "
    if /i "!KILL!"=="s" taskkill /PID %%p /F
)
