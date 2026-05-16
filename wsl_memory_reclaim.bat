@echo off
echo Reclamando memoria de WSL2...
echo NOTA: cierra Docker Desktop antes si esta corriendo.
echo.

wsl --shutdown
echo WSL apagado. Memoria liberada al sistema.
echo.
echo Para ver cuanta RAM consume WSL antes/despues:
echo   Task Manager > Details > Vmmem
echo.
