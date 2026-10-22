set windows-shell := ["cmd.exe", "/c"]

dc := "docker compose"

# Show available options
default:
    @just --list

# Show available options
help:
    @just --list

# Start all services in individual stacks
up: adguard-up bazarr-up byparr-up filebrowser-up homepage-up immich-up jellyseerr-up nginx-up prowlarr-up qbit-up radarr-up sonarr-up

# Stop all services
down: sonarr-down radarr-down qbit-down prowlarr-down nginx-down jellyseerr-down immich-down homepage-down filebrowser-down byparr-down bazarr-down adguard-down

# Restart all services
restart: down up

# Pull latest images for all services
pull: adguard-pull bazarr-pull byparr-pull filebrowser-pull homepage-pull immich-pull jellyseerr-pull nginx-pull prowlarr-pull qbit-pull radarr-pull sonarr-pull

# Show containers status
status:
    {{ dc }} ps -a

# Follow all service logs
logs:
    {{ dc }} logs -f --tail 100

# Run the backup script
backup:
    @python backup.py

# --- AdGuard Home ---
adguard-up:
    cd adguard && {{ dc }} --env-file ../.env up -d

adguard-down:
    cd adguard && {{ dc }} --env-file ../.env down

adguard-restart:
    cd adguard && {{ dc }} --env-file ../.env restart

adguard-logs:
    cd adguard && {{ dc }} --env-file ../.env logs -f

adguard-pull:
    cd adguard && {{ dc }} --env-file ../.env pull

# --- Bazarr ---
bazarr-up:
    cd bazarr && {{ dc }} --env-file ../.env up -d

bazarr-down:
    cd bazarr && {{ dc }} --env-file ../.env down

bazarr-restart:
    cd bazarr && {{ dc }} --env-file ../.env restart

bazarr-logs:
    cd bazarr && {{ dc }} --env-file ../.env logs -f

bazarr-pull:
    cd bazarr && {{ dc }} --env-file ../.env pull

# --- Filebrowser ---
filebrowser-up:
    cd filebrowser && {{ dc }} --env-file ../.env up -d

filebrowser-down:
    cd filebrowser && {{ dc }} --env-file ../.env down

filebrowser-restart:
    cd filebrowser && {{ dc }} --env-file ../.env restart

filebrowser-logs:
    cd filebrowser && {{ dc }} --env-file ../.env logs -f

filebrowser-pull:
    cd filebrowser && {{ dc }} --env-file ../.env pull

# --- ByParr ---
byparr-up:
    cd byparr && {{ dc }} --env-file ../.env up -d

byparr-down:
    cd byparr && {{ dc }} --env-file ../.env down

byparr-restart:
    cd byparr && {{ dc }} --env-file ../.env restart

byparr-logs:
    cd byparr && {{ dc }} --env-file ../.env logs -f

byparr-pull:
    cd byparr && {{ dc }} --env-file ../.env pull

# --- Homepage ---
homepage-up:
    cd homepage && {{ dc }} --env-file ../.env up -d

homepage-down:
    cd homepage && {{ dc }} --env-file ../.env down

homepage-restart:
    cd homepage && {{ dc }} --env-file ../.env restart

homepage-logs:
    cd homepage && {{ dc }} --env-file ../.env logs -f

homepage-pull:
    cd homepage && {{ dc }} --env-file ../.env pull

# --- Immich ---
immich-up:
    cd immich && {{ dc }} --env-file ../.env up -d

immich-down:
    cd immich && {{ dc }} --env-file ../.env down

immich-restart:
    cd immich && {{ dc }} --env-file ../.env restart

immich-logs:
    cd immich && {{ dc }} --env-file ../.env logs -f

immich-pull:
    cd immich && {{ dc }} --env-file ../.env pull

# --- Jellyseerr ---
jellyseerr-up:
    cd jellyseerr && {{ dc }} --env-file ../.env up -d

jellyseerr-down:
    cd jellyseerr && {{ dc }} --env-file ../.env down

jellyseerr-restart:
    cd jellyseerr && {{ dc }} --env-file ../.env restart

jellyseerr-logs:
    cd jellyseerr && {{ dc }} --env-file ../.env logs -f

jellyseerr-pull:
    cd jellyseerr && {{ dc }} --env-file ../.env pull

# --- Nginx ---
nginx-up:
    cd nginx && {{ dc }} --env-file ../.env up -d

nginx-down:
    cd nginx && {{ dc }} --env-file ../.env down

nginx-restart:
    cd nginx && {{ dc }} --env-file ../.env restart

nginx-logs:
    cd nginx && {{ dc }} --env-file ../.env logs -f

nginx-pull:
    cd nginx && {{ dc }} --env-file ../.env pull

# --- Prowlarr ---
prowlarr-up:
    cd prowlarr && {{ dc }} --env-file ../.env up -d

prowlarr-down:
    cd prowlarr && {{ dc }} --env-file ../.env down

prowlarr-restart:
    cd prowlarr && {{ dc }} --env-file ../.env restart

prowlarr-logs:
    cd prowlarr && {{ dc }} --env-file ../.env logs -f

prowlarr-pull:
    cd prowlarr && {{ dc }} --env-file ../.env pull

# --- qBittorrent ---
qbit-up:
    cd qbittorrent && {{ dc }} --env-file ../.env up -d

qbit-down:
    cd qbittorrent && {{ dc }} --env-file ../.env down

qbit-restart:
    cd qbittorrent && {{ dc }} --env-file ../.env restart

qbit-logs:
    cd qbittorrent && {{ dc }} --env-file ../.env logs -f

qbit-pull:
    cd qbittorrent && {{ dc }} --env-file ../.env pull

# --- Radarr ---
radarr-up:
    cd radarr && {{ dc }} --env-file ../.env up -d

radarr-down:
    cd radarr && {{ dc }} --env-file ../.env down

radarr-restart:
    cd radarr && {{ dc }} --env-file ../.env restart

radarr-logs:
    cd radarr && {{ dc }} --env-file ../.env logs -f

radarr-pull:
    cd radarr && {{ dc }} --env-file ../.env pull

# --- Sonarr ---
sonarr-up:
    cd sonarr && {{ dc }} --env-file ../.env up -d

sonarr-down:
    cd sonarr && {{ dc }} --env-file ../.env down

sonarr-restart:
    cd sonarr && {{ dc }} --env-file ../.env restart

sonarr-logs:
    cd sonarr && {{ dc }} --env-file ../.env logs -f

sonarr-pull:
    cd sonarr && {{ dc }} --env-file ../.env pull
