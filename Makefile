DC = docker compose

.PHONY: help up down restart pull status ps logs mc-cli

help:
	@echo "Available options:"
	@echo "  make up           - Start all services in individual stacks"
	@echo "  make down         - Stop all services"
	@echo "  make restart      - Restart all services"
	@echo "  make pull         - Pull latest images"
	@echo "  make status       - Show containers status"
	@echo "  make backup       - Run the backup script"
	@echo ""
	@echo "Individual services:"
	@echo "  make adguard-[up|down|restart|logs]"
	@echo "  make bazarr-[up|down|restart|logs]"
	@echo "  make filebrowser-[up|down|restart|logs]"
	@echo "  make flaresolverr-[up|down|restart|logs]"
	@echo "  make homepage-[up|down|restart|logs]"
	@echo "  make immich-[up|down|restart|logs]"
	@echo "  make jellyseerr-[up|down|restart|logs]"
	@echo "  make mc-[up|down|restart|logs|cli]"
	@echo "  make nginx-[up|down|restart|logs]"
	@echo "  make prowlarr-[up|down|restart|logs]"
	@echo "  make qbit-[up|down|restart|logs]"
	@echo "  make radarr-[up|down|restart|logs]"
	@echo "  make sonarr-[up|down|restart|logs]"

up: adguard-up bazarr-up filebrowser-up flaresolverr-up homepage-up immich-up jellyseerr-up mc-up nginx-up prowlarr-up qbit-up radarr-up sonarr-up

down: sonarr-down radarr-down qbit-down prowlarr-down nginx-down mc-down jellyseerr-down immich-down homepage-down flaresolverr-down filebrowser-down bazarr-down adguard-down

restart: down up

pull: adguard-pull bazarr-pull filebrowser-pull flaresolverr-pull homepage-pull immich-pull jellyseerr-pull mc-pull nginx-pull prowlarr-pull qbit-pull radarr-pull sonarr-pull

status:
	$(DC) ps -a

logs:
	$(DC) ps -a

backup:
	@cmd /c "backup.bat"

adguard-up:
	cd adguard && $(DC) --env-file ../.env up -d

adguard-down:
	cd adguard && $(DC) --env-file ../.env down

adguard-restart:
	cd adguard && $(DC) --env-file ../.env restart

adguard-logs:
	cd adguard && $(DC) --env-file ../.env logs -f

adguard-pull:
	cd adguard && $(DC) --env-file ../.env pull

bazarr-up:
	cd bazarr && $(DC) --env-file ../.env up -d

bazarr-down:
	cd bazarr && $(DC) --env-file ../.env down

bazarr-restart:
	cd bazarr && $(DC) --env-file ../.env restart

bazarr-logs:
	cd bazarr && $(DC) --env-file ../.env logs -f

bazarr-pull:
	cd bazarr && $(DC) --env-file ../.env pull

filebrowser-up:
	cd filebrowser && $(DC) --env-file ../.env up -d

filebrowser-down:
	cd filebrowser && $(DC) --env-file ../.env down

filebrowser-restart:
	cd filebrowser && $(DC) --env-file ../.env restart

filebrowser-logs:
	cd filebrowser && $(DC) --env-file ../.env logs -f

filebrowser-pull:
	cd filebrowser && $(DC) --env-file ../.env pull

flaresolverr-up:
	cd flaresolverr && $(DC) --env-file ../.env up -d

flaresolverr-down:
	cd flaresolverr && $(DC) --env-file ../.env down

flaresolverr-restart:
	cd flaresolverr && $(DC) --env-file ../.env restart

flaresolverr-logs:
	cd flaresolverr && $(DC) --env-file ../.env logs -f

flaresolverr-pull:
	cd flaresolverr && $(DC) --env-file ../.env pull

homepage-up:
	cd homepage && $(DC) --env-file ../.env up -d

homepage-down:
	cd homepage && $(DC) --env-file ../.env down

homepage-restart:
	cd homepage && $(DC) --env-file ../.env restart

homepage-logs:
	cd homepage && $(DC) --env-file ../.env logs -f

homepage-pull:
	cd homepage && $(DC) --env-file ../.env pull

immich-up:
	cd immich && $(DC) --env-file ../.env --env-file .env up -d

immich-down:
	cd immich && $(DC) --env-file ../.env --env-file .env down

immich-restart:
	cd immich && $(DC) --env-file ../.env --env-file .env restart

immich-logs:
	cd immich && $(DC) --env-file ../.env --env-file .env logs -f

immich-pull:
	cd immich && $(DC) --env-file ../.env --env-file .env pull

jellyseerr-up:
	cd jellyseerr && $(DC) --env-file ../.env up -d

jellyseerr-down:
	cd jellyseerr && $(DC) --env-file ../.env down

jellyseerr-restart:
	cd jellyseerr && $(DC) --env-file ../.env restart

jellyseerr-logs:
	cd jellyseerr && $(DC) --env-file ../.env logs -f

jellyseerr-pull:
	cd jellyseerr && $(DC) --env-file ../.env pull

mc-up:
	cd minecraft && $(DC) --env-file ../.env up -d

mc-down:
	cd minecraft && $(DC) --env-file ../.env down

mc-restart:
	cd minecraft && $(DC) --env-file ../.env restart

mc-logs:
	cd minecraft && $(DC) --env-file ../.env logs -f

mc-cli:
	cd minecraft && $(DC) --env-file ../.env exec -it minecraft-server rcon-cli

mc-pull:
	cd minecraft && $(DC) --env-file ../.env pull

nginx-up:
	cd nginx && $(DC) --env-file ../.env up -d

nginx-down:
	cd nginx && $(DC) --env-file ../.env down

nginx-restart:
	cd nginx && $(DC) --env-file ../.env restart

nginx-logs:
	cd nginx && $(DC) --env-file ../.env logs -f

nginx-pull:
	cd nginx && $(DC) --env-file ../.env pull

prowlarr-up:
	cd prowlarr && $(DC) --env-file ../.env up -d

prowlarr-down:
	cd prowlarr && $(DC) --env-file ../.env down

prowlarr-restart:
	cd prowlarr && $(DC) --env-file ../.env restart

prowlarr-logs:
	cd prowlarr && $(DC) --env-file ../.env logs -f

prowlarr-pull:
	cd prowlarr && $(DC) --env-file ../.env pull

qbit-up:
	cd qbittorrent && $(DC) --env-file ../.env up -d

qbit-down:
	cd qbittorrent && $(DC) --env-file ../.env down

qbit-restart:
	cd qbittorrent && $(DC) --env-file ../.env restart

qbit-logs:
	cd qbittorrent && $(DC) --env-file ../.env logs -f

qbit-pull:
	cd qbittorrent && $(DC) --env-file ../.env pull

radarr-up:
	cd radarr && $(DC) --env-file ../.env up -d

radarr-down:
	cd radarr && $(DC) --env-file ../.env down

radarr-restart:
	cd radarr && $(DC) --env-file ../.env restart

radarr-logs:
	cd radarr && $(DC) --env-file ../.env logs -f

radarr-pull:
	cd radarr && $(DC) --env-file ../.env pull

sonarr-up:
	cd sonarr && $(DC) --env-file ../.env up -d

sonarr-down:
	cd sonarr && $(DC) --env-file ../.env down

sonarr-restart:
	cd sonarr && $(DC) --env-file ../.env restart

sonarr-logs:
	cd sonarr && $(DC) --env-file ../.env logs -f

sonarr-pull:
	cd sonarr && $(DC) --env-file ../.env pull
