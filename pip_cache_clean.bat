@echo off
echo [pip cache]
pip cache info 2>nul
echo.
pip cache purge 2>nul || echo pip no encontrado

echo.
echo [uv cache - si instalado]
uv cache clean 2>nul || echo uv no encontrado

echo.
echo Listo.
