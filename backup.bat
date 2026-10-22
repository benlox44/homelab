@echo off
setlocal
cd /d "%~dp0"

echo ==================================================
echo   HOMELAB BACKUP STARTED
echo   Date/Time: %date% %time%
echo ==================================================

python backup.py
if %ERRORLEVEL% equ 0 (
    echo [OK] Homelab backup completed successfully.
) else (
    echo [ERROR] Homelab backup failed with exit code %ERRORLEVEL%.
)
