@echo off
setlocal enabledelayedexpansion
set TOOLS=%~dp0

:MENU
cls
echo ============================================
echo  TOOLS MENU
echo ============================================
echo.
echo  --- MANTENIMIENTO ---
echo  [1]  disk_summary         Resumen de discos
echo  [2]  clean_temp           Limpiar Temp + npm + Chrome
echo  [3]  find_large_files     Archivos grandes en C:\Users
echo  [4]  node_modules_cleaner Limpiar node_modules
echo  [5]  pip_cache_clean      Limpiar cache pip/uv
echo  [6]  vscode_cleanup       Limpiar cache VS Code
echo  [7]  git_cleanup          Git GC en todos los repos
echo.
echo  --- DOCKER / WSL ---
echo  [8]  docker_prune         Docker system prune
echo  [9]  compact_docker       Compactar .vhdx (Admin)
echo  [10] wsl_memory_reclaim   Liberar RAM de WSL2
echo.
echo  --- DEV ---
echo  [11] dev_env_check        Versiones de herramientas
echo  [12] port_killer          Matar proceso por puerto
echo  [13] network_check        IP, DNS, puertos
echo  [14] move_to_drive_symlink Mover carpeta + symlink
echo  [15] startup_check        Programas al inicio
echo.
echo  --- SEGURIDAD ---
echo  [16] secrets_scan         Buscar secrets en disco
echo  [17] security_check       Firewall, puertos, Defender
echo  [18] git_secrets_audit    Secrets en historial git
echo.
echo  --- COMBOS ---
echo  [A]  Mantenimiento completo (2,4,5,6,7,8)
echo  [B]  Limpieza profunda     (2,4,5,6,7,8,9) - requiere Admin
echo  [C]  Auditoria seguridad  (16,17,18)
echo.
echo  [0]  Salir
echo.
set /p OPT="Opcion: "

if "%OPT%"=="1"  call "%TOOLS%disk_summary.bat"          & goto MENU
if "%OPT%"=="2"  call "%TOOLS%clean_temp.bat"            & goto MENU
if "%OPT%"=="3"  call "%TOOLS%find_large_files.bat"      & goto MENU
if "%OPT%"=="4"  call "%TOOLS%node_modules_cleaner.bat"  & goto MENU
if "%OPT%"=="5"  call "%TOOLS%pip_cache_clean.bat"       & goto MENU
if "%OPT%"=="6"  call "%TOOLS%vscode_cleanup.bat"        & goto MENU
if "%OPT%"=="7"  call "%TOOLS%git_cleanup.bat"           & goto MENU
if "%OPT%"=="8"  call "%TOOLS%docker_prune.bat"          & goto MENU
if "%OPT%"=="9"  call "%TOOLS%compact_docker.bat"        & goto MENU
if "%OPT%"=="10" call "%TOOLS%wsl_memory_reclaim.bat"    & goto MENU
if "%OPT%"=="11" call "%TOOLS%dev_env_check.bat"         & goto MENU
if "%OPT%"=="12" call "%TOOLS%port_killer.bat"           & goto MENU
if "%OPT%"=="13" call "%TOOLS%network_check.bat"         & goto MENU
if "%OPT%"=="14" call "%TOOLS%move_to_drive_symlink.bat" & goto MENU
if "%OPT%"=="15" call "%TOOLS%startup_check.bat"         & goto MENU
if "%OPT%"=="16" call "%TOOLS%secrets_scan.bat"          & goto MENU
if "%OPT%"=="17" call "%TOOLS%security_check.bat"        & goto MENU
if "%OPT%"=="18" call "%TOOLS%git_secrets_audit.bat"     & goto MENU

if /i "%OPT%"=="A" (
    call "%TOOLS%clean_temp.bat"
    call "%TOOLS%node_modules_cleaner.bat"
    call "%TOOLS%pip_cache_clean.bat"
    call "%TOOLS%vscode_cleanup.bat"
    call "%TOOLS%git_cleanup.bat"
    call "%TOOLS%docker_prune.bat"
    goto MENU
)
if /i "%OPT%"=="B" (
    call "%TOOLS%clean_temp.bat"
    call "%TOOLS%node_modules_cleaner.bat"
    call "%TOOLS%pip_cache_clean.bat"
    call "%TOOLS%vscode_cleanup.bat"
    call "%TOOLS%git_cleanup.bat"
    call "%TOOLS%docker_prune.bat"
    call "%TOOLS%compact_docker.bat"
    goto MENU
)
if /i "%OPT%"=="C" (
    call "%TOOLS%secrets_scan.bat"
    call "%TOOLS%security_check.bat"
    call "%TOOLS%git_secrets_audit.bat"
    goto MENU
)
if "%OPT%"=="0" exit
goto MENU
