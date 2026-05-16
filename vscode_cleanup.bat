@echo off
echo Limpiando VS Code cache y logs...
echo.
echo [Cache]
rd /s /q "%APPDATA%\Code\Cache" 2>nul
rd /s /q "%APPDATA%\Code\CachedData" 2>nul
rd /s /q "%APPDATA%\Code\CachedExtensionVSIXs" 2>nul
rd /s /q "%APPDATA%\Code\Code Cache" 2>nul
echo [Logs]
rd /s /q "%APPDATA%\Code\logs" 2>nul
echo [Crash reports]
rd /s /q "%APPDATA%\Code\Crashpad" 2>nul

echo.
echo Extensiones instaladas:
code --list-extensions 2>nul
echo.
echo Listo. Reinicia VS Code.
