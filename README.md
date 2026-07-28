# Homelab Stack

A cleanly organized, Make-driven self-hosted environment using Docker Compose.

## 📦 Services

All services are continuously sorted A-Z and routed through the unified `caddy_net` Docker network.

| Service | Description | Port |
| :--- | :--- | :--- |
| **AdGuard Home** | Network-wide ad blocking & DNS | `53`, `3000`, `8083` |
| **AudioPlayer** | Minecraft MP3 uploader | `5000` |
| **Bazarr** | Subtitle management | `6767` |
| **ByParr** | Cloudflare bypass server | `8191` |
| **Filebrowser** | Web file manager | `8084` |
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
| `make logs` | Follow all service logs |
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

The portable `backup.py` script handles cold backups with strict **fail-fast** and **auto-recovery** policies:
1. Creates a timestamped folder inside `BACKUP_DIR` using the cookievale-style `YYYY-MM-DD_HHMMSS` format.
2. Stores the Immich database dump compressed as `config/immich_db_dump.sql.gz` and copies the current `.env` alongside it.
3. Gracefully brings down the entire Homelab (`make down`) to free locked files before syncing the config and media trees.
4. Synchronizes the repository config and media folders into `config/homelab` and `media/*` inside that timestamped backup folder.
5. Keeps only the last 2 timestamped backups, so the destination stays small while still retaining a fallback copy.
