@echo off
echo ============================================
echo  RESUMEN DE DISCO
echo ============================================
wmic logicaldisk get DeviceID,Size,FreeSpace,VolumeName /format:csv 2>nul | powershell -Command "$input | ConvertFrom-Csv | Where-Object {$_.Size -ne ''} | ForEach-Object { $free=[math]::Round([long]$_.FreeSpace/1GB,2); $total=[math]::Round([long]$_.Size/1GB,2); $used=[math]::Round($total-$free,2); Write-Host ('{0,-4} {1,8} GB usado  {2,8} GB libre  {3,8} GB total  [{4}]' -f $_.DeviceID, $used, $free, $total, $_.VolumeName) }"
echo.
echo ============================================
echo  TOP CARPETAS EN C:\Users\%USERNAME%
echo ============================================
powershell -Command "Get-ChildItem 'C:\Users\%USERNAME%' -ErrorAction SilentlyContinue | ForEach-Object { $s=(Get-ChildItem $_.FullName -Recurse -ErrorAction SilentlyContinue | Measure-Object Length -Sum).Sum; [PSCustomObject]@{GB=[math]::Round($s/1GB,2);Path=$_.FullName} } | Sort-Object GB -Descending | Select-Object -First 15 | Format-Table -AutoSize"
