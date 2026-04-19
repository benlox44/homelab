# Homelab Stack

A cleanly organized, Make-driven self-hosted environment using Docker Compose.

## 📦 Services

All services are continuously sorted A-Z and routed through the unified `caddy_net` Docker network.

| Service | Description | Port |
| :--- | :--- | :--- |
| **AdGuard Home** | Network-wide ad blocking & DNS | `53`, `3000`, `8083` |
| **Bazarr** | Subtitle management | `6767` |
| **Filebrowser** | Web file manager | `8084` |
| **FlareSolverr** | Cloudflare bypass server | `8191` |
| **Homepage** | Application dashboard | `3001` |
| **Immich** | Self-hosted photo & video backup | `2283` |
| **Jellyseerr** | Media request management | `5055` |
| **Minecraft** | Minecraft Server & Squaremap | `25565` |
| **Nginx** | Nginx Proxy Manager (Reverse proxy) | `80`, `81`, `443` |
| **Prowlarr** | Indexer manager | `9696` |
| **qBittorrent** | Torrent client | `8080`, `6881` |
| **Radarr** | Movie collection manager | `7878` |
| **Sonarr** | TV show collection manager | `8989` |

## 🚀 Getting Started

### 1. Prerequisites
- **Docker** and **Docker Compose**
- **Make**
- Dedicated media storage drives.

### 2. Network Setup
Create the external network for internal proxying:
```bash
docker network create caddy_net
```

### 3. Environment Configuration
Define your base variables inside the `.env` root file:
```bash
copy .env.example .env
```

### 4. Start the Stack
```bash
make up
```

## 🛠️ Commands (Makefile)

The entire infrastructure is managed via simple `make` targets.

### Global Actions
| Command | Action |
| :--- | :--- |
| `make up` | Boot all services |
| `make down` | Tear down all containers |
| `make restart` | Rebuild and restart the stack |
| `make status` | Print current container status |
| `make pull` | Fetch the latest Docker images |
| `make backup` | Trigger the automated backup script |

### Individual Control
Syntax: `make <service>-<action>`
```bash
make radarr-up
make immich-down
make nginx-restart
make adguard-logs
```

## 💾 Backup System

Run backups safely by triggering:
```bash
make backup
```

The localized `backup.bat` script handles cold backups with strict **fail-fast** and **auto-recovery** policies:
1. Performs a live SQL dump of the Immich Postgres database.
2. Gracefully brings down the entire Homelab (`make down`) to free locked files.
3. Synchronizes (Mirror) `app_data` configurations and `Media` to your isolated `BACKUP_DEST` via Robocopy.
4. Auto-ignores volatile sockets (`.sock`, `.pid`) to prevent interruption.
5. Automatically resumes all services (`make up`), even if the backup encounters an error along the way, guaranteeing zero unnotified downtime.
