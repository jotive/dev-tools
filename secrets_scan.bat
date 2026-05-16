@echo off
:: Busca archivos con posibles secrets en carpetas de desarrollo
:: NO muestra contenido, solo rutas — para auditoria
echo ============================================
echo  SECRETS SCAN (solo rutas, sin contenido)
echo ============================================
echo.
echo [Archivos .env en DEV]
powershell -Command "Get-ChildItem 'C:\Users\%USERNAME%' -Recurse -ErrorAction SilentlyContinue -Include '.env','.env.local','.env.production','.env.*' | Where-Object { $_.FullName -notmatch 'node_modules' } | Select-Object FullName"
echo.
echo [Archivos con credenciales tipicas]
powershell -Command "Get-ChildItem 'C:\Users\%USERNAME%' -Recurse -ErrorAction SilentlyContinue -Include 'credentials.json','secrets.json','service-account*.json','*keyfile*.json','*.pem','*.p12','*.pfx' | Where-Object { $_.FullName -notmatch 'node_modules' } | Select-Object FullName"
echo.
echo [SSH keys]
dir "%USERPROFILE%\.ssh" 2>nul
echo.
echo [Buscar 'password' o 'secret' en archivos .js .ts .py (solo nombre archivo si hay match)]
powershell -Command "Get-ChildItem 'C:\Users\%USERNAME%\DEV' -Recurse -ErrorAction SilentlyContinue -Include '*.js','*.ts','*.py','*.env' | Where-Object { $_.FullName -notmatch 'node_modules|\.git' } | Select-String -Pattern 'password\s*=\s*[\"''][^\"'']{6,}|secret\s*=\s*[\"''][^\"'']{6,}|api_key\s*=\s*[\"''][^\"'']{6,}' -ErrorAction SilentlyContinue | Select-Object -ExpandProperty Path -Unique"
echo.
