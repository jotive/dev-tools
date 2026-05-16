@echo off
echo Cerrando Docker Desktop y WSL...
taskkill /IM "Docker Desktop.exe" /F >nul 2>&1
taskkill /IM "dockerd.exe" /F >nul 2>&1
taskkill /IM "com.docker.backend.exe" /F >nul 2>&1
taskkill /IM "com.docker.proxy.exe" /F >nul 2>&1
wsl --shutdown >nul 2>&1

echo Esperando 8 segundos...
timeout /t 8 /nobreak >nul

echo.
echo Compactando discos virtuales de Docker...
echo.

:: Ajusta DOCKER_VHDX_DIR a la ruta donde Docker Desktop almacena los discos virtuales.
:: Por defecto suele ser: %LOCALAPPDATA%\Docker\wsl  o una unidad alternativa.
if not defined DOCKER_VHDX_DIR set DOCKER_VHDX_DIR=%LOCALAPPDATA%\Docker\wsl

echo select vdisk file="%DOCKER_VHDX_DIR%\disk\docker_data.vhdx" > %TEMP%\diskpart_docker.txt
echo attach vdisk readonly >> %TEMP%\diskpart_docker.txt
echo compact vdisk >> %TEMP%\diskpart_docker.txt
echo detach vdisk >> %TEMP%\diskpart_docker.txt
echo select vdisk file="%DOCKER_VHDX_DIR%\data\ext4.vhdx" >> %TEMP%\diskpart_docker.txt
echo attach vdisk readonly >> %TEMP%\diskpart_docker.txt
echo compact vdisk >> %TEMP%\diskpart_docker.txt
echo detach vdisk >> %TEMP%\diskpart_docker.txt
echo exit >> %TEMP%\diskpart_docker.txt

diskpart /s %TEMP%\diskpart_docker.txt

echo.
echo Listo. Puedes abrir Docker Desktop de nuevo.
