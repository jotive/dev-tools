@echo off
echo Limpiando archivos temporales...
echo.

echo [1/4] AppData\Local\Temp
rd /s /q "%LOCALAPPDATA%\Temp" 2>nul
mkdir "%LOCALAPPDATA%\Temp" 2>nul

echo [2/4] Windows\Temp
rd /s /q "%WINDIR%\Temp" 2>nul
mkdir "%WINDIR%\Temp" 2>nul

echo [3/4] npm cache
call npm cache clean --force 2>nul

echo [4/4] Chrome cache
rd /s /q "%LOCALAPPDATA%\Google\Chrome\User Data\Default\Cache" 2>nul

echo.
echo Listo.
