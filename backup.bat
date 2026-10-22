@echo off
setlocal
cd /d "%~dp0"

echo ==================================================
echo   INICIANDO RESPALDO HOMELAB
echo   Fecha/Hora: %date% %time%
echo ==================================================

python backup.py
if %ERRORLEVEL% equ 0 (
    echo [OK] Homelab respaldado con exito.
) else (
    echo [ERROR] Homelab fallo con codigo %ERRORLEVEL%.
)
