@echo off
:: Verifica que .env y archivos sensibles esten en .gitignore
:: Revisa si hay secrets commiteados en historial git
echo ============================================
echo  GIT SECRETS AUDIT
echo ============================================
echo.
echo [Repos encontrados]
powershell -Command "Get-ChildItem 'C:\Users\%USERNAME%\DEV' -Recurse -ErrorAction SilentlyContinue -Filter '.git' -Directory | ForEach-Object { $_.Parent.FullName }"
echo.

powershell -Command ^
"Get-ChildItem 'C:\Users\%USERNAME%\DEV' -Recurse -ErrorAction SilentlyContinue -Filter '.git' -Directory | ForEach-Object { " ^
"  $repo = $_.Parent.FullName; " ^
"  Set-Location $repo; " ^
"  Write-Host '--- '$repo -ForegroundColor Cyan; " ^
"  $gi = Join-Path $repo '.gitignore'; " ^
"  if (Test-Path $gi) { " ^
"    $content = Get-Content $gi -Raw; " ^
"    if ($content -notmatch '\.env') { Write-Host '  WARN: .env NO esta en .gitignore' -ForegroundColor Red } else { Write-Host '  OK: .env en .gitignore' -ForegroundColor Green } " ^
"  } else { Write-Host '  WARN: No existe .gitignore' -ForegroundColor Red } " ^
"  $leaked = git log --all -p --follow -- '*.env' '*.pem' 'credentials.json' 'secrets.json' 2>$null | Select-String 'password|secret|api_key|token' -ErrorAction SilentlyContinue; " ^
"  if ($leaked) { Write-Host '  WARN: Posibles secrets en historial git' -ForegroundColor Red; $leaked | Select-Object -First 3 } else { Write-Host '  OK: Sin secrets obvios en historial' -ForegroundColor Green } " ^
"}"

echo.
