# Selfhost Stack

Self-hosted media server and services management using Docker Compose.

## Services

- **Jellyfin** - Media streaming server
- **Nginx Proxy Manager** - Reverse proxy with SSL (Ports: 80, 443, 81)
- **Radarr** - Movie management (Port: 7878)
- **Sonarr** - TV shows management (Port: 8989)
- **Bazarr** - Subtitles management (Port: 6767)
- **Prowlarr** - Indexer manager (Port: 9696)
- **qBittorrent** - Torrent client (Port: 8080)
- **FlareSolverr** - Cloudflare bypass (Port: 8191)
- **Immich** - Photo/video backup (Port: 2283)
- **Minecraft Survival** - Modded server (Port: 25565)

## Prerequisites

- **Docker** and **Docker Compose** installed
- **Make** (Windows: `choco install make` or use WSL)
- External HDD or dedicated disk for media storage
- Docker network `caddy_net` created (see below)

## Initial Setup

### 1. Clone the repository

```bash
git clone <your-repo-url>
cd Selfhost
```

### 2. Configure Environment

Copy the example environment files and adjust the values to match your system:

```bash
# Main environment variables
cp .env.example .env

# Service-specific environment variables
cp qbittorrent/.env.example qbittorrent/.env
cp immich/.env.example immich/.env
```

### 3. Create External Network

The services rely on an external network named `caddy_net`:

```bash
docker network create caddy_net
```

### 4. Create media storage structure

Create this folder structure on your external drive:

```
C:\Media\  (or E:\, D:\, etc.)
├── jellyfin\
│   ├── library\
│   │   ├── movies\
│   │   └── shows\
│   └── downloads\
└── immich\
    ├── library\
    ├── upload\
    ├── thumbs\
    ├── encoded-video\
    ├── profile\
    └── backups\
```

### 5. Start Services

You can start specific services using the Makefile:

```bash
# Start all services
make up

# Start specific services
make nginx-up
make mc-up
make immich-up
# ... and so on
```

## Commands

### Global

| Command | Description |
|---------|-------------|
| `make up` | Start all services |
| `make down` | Stop all services |
| `make restart` | Restart all services |
| `make pull` | Pull latest Docker images |
| `make status` | Show containers status |

### Individual Services

Syntax: `make <service>-<action>`

Available actions: `up`, `down`, `restart`, `logs`

**Special commands:**
```bash
make mc-cli  # Open Minecraft RCON console
```

## Post-Installation Configuration

### Media Management

1. **Radarr** (`http://localhost:7878`):
   - Set root folder: `/data/jellyfin/library/movies`
   - Add Prowlarr indexers
   - Connect qBittorrent download client

2. **Sonarr** (`http://localhost:8989`):
   - Set root folder: `/data/jellyfin/library/shows`
   - Add Prowlarr indexers
   - Connect qBittorrent download client

3. **Bazarr** (`http://localhost:6767`):
   - Connect Radarr and Sonarr
   - Add subtitle providers

4. **Prowlarr** (`http://localhost:9696`):
   - Add indexers (use FlareSolverr proxy for protected sites)
   - Sync with Radarr/Sonarr

### Nginx Proxy Manager

Access at `http://localhost:81`
- Default credentials: `admin@example.com` / `changeme`
- Configure proxy hosts for your services
- Set up SSL certificates
