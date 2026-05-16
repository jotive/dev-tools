@echo off
if exist "%~dp0.env" (
    for /f "usebackq tokens=1,2 delims==" %%a in ("%~dp0.env") do set %%a=%%b
)
if not defined TRUSTED_USERS set TRUSTED_USERS=WDAGUtilityAccount
echo ============================================
echo  SECURITY CHECK
echo ============================================
echo.

echo [1/6] Windows Defender
powershell -Command "$s = Get-MpComputerStatus; $ok = $s.AMServiceEnabled -and $s.RealTimeProtectionEnabled -and $s.AntivirusEnabled; if ($ok) { Write-Host '[OK]    Defender activo' -ForegroundColor Green } else { Write-Host '[ALERT] Defender DESACTIVADO - sin proteccion activa' -ForegroundColor Red }; Write-Host ('        AMService={0}  RealTime={1}  AV={2}  AS={3}' -f $s.AMServiceEnabled,$s.RealTimeProtectionEnabled,$s.AntivirusEnabled,$s.AntispywareEnabled)"

echo.
echo [2/6] Firewall
powershell -Command "$profiles = netsh advfirewall show allprofiles state; $off = $profiles | Select-String 'OFF'; if ($off) { Write-Host '[ALERT] Firewall OFF en perfil(es):' -ForegroundColor Red; $off | ForEach-Object { Write-Host ('        ' + $_) } } else { Write-Host '[OK]    Firewall ON en todos los perfiles' -ForegroundColor Green }"

echo.
echo [3/6] Puertos escuchando (con proceso)
netstat -ano | findstr "LISTENING" > %TEMP%\ports_sec.txt
powershell -Command "$risky = @(21,23,25,3389,5900,4444,1337,8080); Get-Content '%TEMP%\ports_sec.txt' | ForEach-Object { if ($_ -match ':(\d+)\s.*LISTENING\s+(\d+)') { $port=[int]$Matches[1]; $procId=$Matches[2]; $proc=(Get-Process -Id $procId -ErrorAction SilentlyContinue).Name; $tag = if ($risky -contains $port) { '[WARN] ' } else { '       ' }; Write-Host ('{0}Port {1,-6} PID {2,-6} {3}' -f $tag,$port,$procId,$proc) } } | Sort-Object"

echo.
echo [4/6] Conexiones salientes externas
powershell -Command "$conns = netstat -an | Select-String 'ESTABLISHED' | Where-Object { $_ -notmatch '127\.0\.0\.1' -and $_ -notmatch '\[::1\]' }; Write-Host ('        ' + $conns.Count + ' conexiones externas establecidas'); $http = $conns | Where-Object { $_ -match ':80\s' }; if ($http) { Write-Host '[WARN]  Conexiones HTTP sin cifrar (puerto 80):' -ForegroundColor Yellow; $http | ForEach-Object { Write-Host ('        ' + ($_ -replace '\s+', ' ')) } } else { Write-Host '[OK]    No hay conexiones HTTP sin cifrar' -ForegroundColor Green }"

echo.
echo [5/6] Usuarios locales
powershell -Command "$trusted = $env:TRUSTED_USERS -split ','; Get-LocalUser | Where-Object { $_.Enabled } | ForEach-Object { $tag = if ($_.Name -notin $trusted) { '[WARN] ' } else { '[OK]   ' }; Write-Host ('{0}{1,-25} LastLogon: {2}' -f $tag,$_.Name,$_.LastLogon) }"

echo.
echo [6/6] Ollama - verificar bind address
powershell -Command "$ollamaPort = netstat -ano | Select-String ':11434.*LISTENING'; if ($ollamaPort) { $bind = ($ollamaPort -split '\s+')[2]; if ($bind -match '^0\.0\.0\.0') { Write-Host '[WARN]  Ollama escucha en 0.0.0.0:11434 - expuesto en red local' -ForegroundColor Yellow } else { Write-Host ('[OK]    Ollama escucha en ' + $bind + ' (restringido)') -ForegroundColor Green } } else { Write-Host '        Ollama no esta corriendo' }"

echo.
echo [Actualizaciones recientes]
powershell -Command "Get-HotFix | Sort-Object InstalledOn -Descending | Select-Object -First 5 | Format-Table HotFixID, InstalledOn -AutoSize"

echo ============================================
echo  FIN SECURITY CHECK
echo ============================================
