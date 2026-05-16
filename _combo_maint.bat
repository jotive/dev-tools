@echo off
call "%~dp0clean_temp.bat"
call "%~dp0node_modules_cleaner.bat"
call "%~dp0pip_cache_clean.bat"
call "%~dp0vscode_cleanup.bat"
call "%~dp0git_cleanup.bat"
call "%~dp0docker_prune.bat"
