@echo off
echo Git GC + prune en todos los repos bajo C:\Users\%USERNAME%...
echo.

powershell -Command "Get-ChildItem 'C:\Users\%USERNAME%' -Recurse -ErrorAction SilentlyContinue -Filter '.git' -Directory | ForEach-Object { $repo = $_.Parent.FullName; Write-Host '--- '$repo; Set-Location $repo; git gc --prune=now --quiet 2>&1; git remote prune origin --dry-run 2>&1 }"

echo.
echo Listo.
