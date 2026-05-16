@echo off
echo Top 30 archivos mas grandes en C:\ (excluye Windows y Program Files)...
echo Puede tardar 1-2 minutos.
echo.
powershell -Command "Get-ChildItem 'C:\Users' -Recurse -ErrorAction SilentlyContinue -File | Where-Object {$_.Length -gt 100MB} | Sort-Object Length -Descending | Select-Object -First 30 | ForEach-Object { Write-Host ('{0,8} MB  {1}' -f [math]::Round($_.Length/1MB,0), $_.FullName) }"
echo.
