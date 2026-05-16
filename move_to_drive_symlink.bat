@echo off
:: Mueve una carpeta de C: a otro disco y deja un symlink (junction) en su lugar
:: Util para liberar espacio en C: sin cambiar rutas
echo ============================================
echo  MOVER CARPETA + CREAR SYMLINK EN C:
echo ============================================
echo.
echo Ejemplo: mover C:\Users\%USERNAME%\.gradle a D:\Dev\.gradle
echo.
set /p SOURCE="Carpeta origen (ej: C:\Users\%USERNAME%\.gradle): "
set /p DEST="Carpeta destino (ej: D:\Dev\.gradle): "
echo.

if not exist "%SOURCE%" (
    echo ERROR: origen no existe.
    pause & exit
)
if exist "%DEST%" (
    echo ERROR: destino ya existe.
    pause & exit
)

echo Moviendo %SOURCE% a %DEST%...
move "%SOURCE%" "%DEST%"
echo Creando junction...
mklink /J "%SOURCE%" "%DEST%"
echo.
echo Listo. %SOURCE% ahora apunta a %DEST%.
