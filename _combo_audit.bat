@echo off
call "%~dp0secrets_scan.bat"
call "%~dp0security_check.bat"
call "%~dp0git_secrets_audit.bat"
