@echo off
setlocal enabledelayedexpansion

echo === Homelab Backup Started ===

:: 1. Setup & Config
set "APP_DIR=%~dp0"
if "!APP_DIR:~-1!"=="\" set "APP_DIR=!APP_DIR:~0,-1!"
cd /d "!APP_DIR!"

:: Load .env strictly
for /f "usebackq eol=# tokens=1,* delims==" %%A in (".env") do (
    set "VAR=%%B"
    for /l %%I in (1,1,3) do (
        if "!VAR:~-1!"==" " set "VAR=!VAR:~0,-1!"
        if "!VAR:~-1!"=="" set "VAR=!VAR:~0,-1!"
    )
    for /f "delims=" %%C in ("^!VAR^!") do set "VAR=%%C"
    set "%%A=!VAR!"
)

if "!BACKUP_DEST:~-1!"=="\" set "BACKUP_DEST=!BACKUP_DEST:~0,-1!"

if "!MEDIA_ROOT!"=="" ( echo [ERROR] MEDIA_ROOT missing ^& goto :resume_services )
if "!BACKUP_DEST!"=="" ( echo [ERROR] BACKUP_DEST missing ^& goto :resume_services )
if not exist "!BACKUP_DEST!\" ( echo [ERROR] Dest !BACKUP_DEST! offline ^& goto :resume_services )

:: 2. Database Backup
echo [*] Dumping Immich Database...
docker exec -t immich-postgres pg_dumpall -c -U postgres > "!APP_DIR!\immich\immich_db_dump.sql"
if %ERRORLEVEL% NEQ 0 ( echo [ERROR] Immich DB dump failed ^& goto :resume_services )

:: 3. Stop Containers
echo [*] Stopping all containers...
call make down
if %ERRORLEVEL% NEQ 0 ( echo [ERROR] make down failed ^& goto :resume_services )
timeout /t 10 /nobreak > nul

:: 4. Sync Configurations
echo [*] Syncing Homelab config...
set "XD="!APP_DIR!\immich\postgres" "!APP_DIR!\immich\model-cache" "!APP_DIR!\.git" "*logs*" "*log*""
set "XF="ipc-socket" "*.sock" "*.pid" "*.pem""
robocopy "!APP_DIR!" "!BACKUP_DEST!\homelab" /MIR /FFT /Z /XA:H /W:1 /R:1 /SL /XD !XD! /XF !XF!
if %ERRORLEVEL% GEQ 8 ( echo [ERROR] Config sync failed ^& goto :resume_services )

:: 5. Sync Media
echo [*] Syncing Immich Media...
robocopy "!MEDIA_ROOT!immich" "!BACKUP_DEST!\media\immich" /MIR /FFT /Z /XA:H /W:1 /R:1 /SL
if %ERRORLEVEL% GEQ 8 ( echo [ERROR] Immich media sync failed ^& goto :resume_services )

echo [*] Syncing Filebrowser Media...
robocopy "!MEDIA_ROOT!filebrowser" "!BACKUP_DEST!\media\filebrowser" /MIR /FFT /Z /XA:H /W:1 /R:1 /SL
if %ERRORLEVEL% GEQ 8 ( echo [ERROR] Filebrowser media sync failed ^& goto :resume_services )

echo === Backup Completed Successfully ===

:resume_services
echo [*] Ensuring containers are UP...
cd /d "!APP_DIR!"
call make up
if %ERRORLEVEL% NEQ 0 (
    echo [FATAL] make up failed! Containers might be offline.
    exit /b 1
)

echo === Homelab Online ===
exit /b 0
