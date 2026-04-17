DC = docker compose

.PHONY: help up down restart pull status ps logs mc-cli

help:
	@echo "Available options:"
	@echo "  make up           - Start all services"
	@echo "  make down         - Stop all services"
	@echo "  make restart      - Restart all services"
	@echo "  make pull         - Pull latest images"
	@echo "  make status       - Show containers status"
	@echo ""
	@echo "Individual services:"
	@echo "  make adguard-[up|down|restart|logs]"
	@echo "  make bazarr-[up|down|restart|logs]"
    @echo "  make filebrowser-[up|down|restart|logs]"
    @echo "  make flaresolverr-[up|down|restart|logs]"
	@echo "  make immich-[up|down|restart|logs]"
	@echo "  make jellyseerr-[up|down|restart|logs]"
	@echo "  make mc-[up|down|restart|logs|cli]"
	@echo "  make nginx-[up|down|restart|logs]"
	@echo "  make prowlarr-[up|down|restart|logs]"
	@echo "  make qbit-[up|down|restart|logs]"
	@echo "  make radarr-[up|down|restart|logs]"
	@echo "  make sonarr-[up|down|restart|logs]"

up:
	$(DC) up -d

down:
	$(DC) down

restart:
	$(DC) restart

pull:
	$(DC) pull

status:
	$(DC) ps -a

logs:
	$(DC) logs -f

nginx-up:
	$(DC) up -d nginx

nginx-down:
	$(DC) stop nginx && $(DC) rm -f nginx

nginx-restart:
	$(DC) restart nginx

nginx-logs:
	$(DC) logs -f nginx

qbit-up:
	$(DC) up -d qbittorrent

qbit-down:
	$(DC) stop qbittorrent && $(DC) rm -f qbittorrent

qbit-restart:
	$(DC) restart qbittorrent

qbit-logs:
	$(DC) logs -f qbittorrent

mc-up:
	$(DC) up -d mc

mc-down:
	$(DC) stop mc && $(DC) rm -f mc

mc-restart:
	$(DC) restart mc

mc-logs:
	$(DC) logs -f mc

mc-cli:
	$(DC) exec -it mc rcon-cli

prowlarr-up:
	$(DC) up -d prowlarr

prowlarr-down:
	$(DC) stop prowlarr && $(DC) rm -f prowlarr

prowlarr-restart:
	$(DC) restart prowlarr

prowlarr-logs:
	$(DC) logs -f prowlarr

radarr-up:
	$(DC) up -d radarr

radarr-down:
	$(DC) stop radarr && $(DC) rm -f radarr

radarr-restart:
	$(DC) restart radarr

radarr-logs:
	$(DC) logs -f radarr

sonarr-up:
	$(DC) up -d sonarr

sonarr-down:
	$(DC) stop sonarr && $(DC) rm -f sonarr

sonarr-restart:
	$(DC) restart sonarr

sonarr-logs:
	$(DC) logs -f sonarr

bazarr-up:
	$(DC) up -d bazarr

bazarr-down:
	$(DC) stop bazarr && $(DC) rm -f bazarr

bazarr-restart:
	$(DC) restart bazarr

bazarr-logs:
	$(DC) logs -f bazarr

immich-up:
	$(DC) up -d immich-server immich-machine-learning redis database

immich-down:
	$(DC) stop immich-server immich-machine-learning redis database && $(DC) rm -f immich-server immich-machine-learning redis database

immich-restart:
	$(DC) restart immich-server immich-machine-learning redis database

immich-logs:
	$(DC) logs -f immich-server

flaresolverr-up:
	$(DC) up -d flaresolverr

flaresolverr-down:
	$(DC) stop flaresolverr && $(DC) rm -f flaresolverr

flaresolverr-restart:
	$(DC) restart flaresolverr

flaresolverr-logs:
	$(DC) logs -f flaresolverr






adguard-up:
	$(DC) up -d adguard

adguard-down:
	$(DC) stop adguard && $(DC) rm -f adguard

adguard-restart:
	$(DC) restart adguard

adguard-logs:
	$(DC) logs -f adguard


jellyseerr-up:
        $(DC) up -d jellyseerr

jellyseerr-down:
        $(DC) stop jellyseerr && $(DC) rm -f jellyseerr

jellyseerr-restart:
        $(DC) restart jellyseerr

jellyseerr-logs:
        $(DC) logs -f jellyseerr
