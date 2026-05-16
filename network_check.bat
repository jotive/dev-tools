@echo off
echo ============================================
echo  NETWORK CHECK
echo ============================================
echo.
echo [IP local]
ipconfig | findstr /i "IPv4 IPv6 Default Gateway"
echo.
echo [DNS]
ipconfig /all | findstr /i "DNS Servers"
echo.
echo [Conectividad]
ping -n 1 8.8.8.8 | findstr /i "TTL perdido time"
ping -n 1 google.com | findstr /i "TTL perdido time"
echo.
echo [IP publica]
powershell -Command "(Invoke-WebRequest -Uri 'https://api.ipify.org' -UseBasicParsing).Content"
echo.
echo [Puertos en uso (LISTEN)]
netstat -an | findstr "LISTENING" | sort
echo.
