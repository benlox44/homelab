#!/usr/bin/env python3
from __future__ import annotations

import gzip
import logging
import shutil
import subprocess
import sys
from datetime import datetime, timezone
from pathlib import Path


ROOT = Path(__file__).resolve().parent
ENV_FILE = ROOT / ".env"
BACKUP_RETENTION = 2
LOG_FILE = ROOT / "backup.log"

CONFIG_EXCLUDES = [
    ".git",
    "immich/postgres",
    "immich/model-cache",
    "logs",
    "log",
]
CONFIG_FILE_EXCLUDES = ["ipc-socket", "*.sock", "*.pid", "*.pem"]
MEDIA_SOURCES = ["immich", "filebrowser"]


logging.basicConfig(
    level=logging.INFO,
    format="[%(asctime)s] %(message)s",
    datefmt="%Y-%m-%d %H:%M:%S",
    handlers=[
        logging.FileHandler(LOG_FILE),
        logging.StreamHandler(sys.stdout),
    ],
)
log = logging.getLogger(__name__)


def load_env(env_file: Path) -> dict[str, str]:
    env: dict[str, str] = {}
    if not env_file.exists():
        log.error("[ERROR] .env file not found: %s", env_file)
        sys.exit(1)

    for line in env_file.read_text(encoding="utf-8").splitlines():
        stripped = line.strip()
        if not stripped or stripped.startswith("#") or "=" not in stripped:
            continue
        key, _, value = stripped.partition("=")
        key = key.strip()
        value = value.strip()
        if len(value) >= 2 and value[0] == value[-1] and value[0] in ('"', "'"):
            value = value[1:-1]
        env[key] = value

    return env


def is_timestamp_dir(name: str) -> bool:
    if len(name) != 19 or "_" not in name:
        return False
    try:
        datetime.strptime(name, "%Y-%m-%d_%H%M%S").replace(tzinfo=timezone.utc)
        return True
    except ValueError:
        return False


def run_command(command: list[str], *, cwd: Path | None = None) -> None:
    result = subprocess.run(command, cwd=cwd)
    if result.returncode != 0:
        raise RuntimeError(f"Command failed with exit code {result.returncode}: {' '.join(command)}")


def sync_tree(source: Path, target: Path, patterns: list[str]) -> None:
    target.parent.mkdir(parents=True, exist_ok=True)

    if shutil.which("robocopy") and sys.platform.startswith("win"):
        robocopy_dir_excludes: list[str] = []
        robocopy_file_excludes: list[str] = []
        for pattern in patterns:
            if pattern in CONFIG_FILE_EXCLUDES:
                robocopy_file_excludes.append(pattern)
            elif "/" in pattern or pattern.startswith(".") or pattern in {"logs", "log"}:
                robocopy_dir_excludes.append(str(source / pattern) if "/" in pattern or pattern.startswith(".") else pattern)

        args = [
            "robocopy",
            str(source),
            str(target),
            "/MIR",
            "/FFT",
            "/Z",
            "/XA:H",
            "/W:1",
            "/R:1",
            "/SL",
        ]
        if robocopy_dir_excludes:
            args.extend(["/XD", *robocopy_dir_excludes])
        if robocopy_file_excludes:
            args.extend(["/XF", *robocopy_file_excludes])

        result = subprocess.run(args)
        if result.returncode >= 8:
            raise RuntimeError(f"Robocopy failed for {source} -> {target} with exit code {result.returncode}")
        return

    if shutil.which("rsync"):
        args = ["rsync", "-a", "--delete"]
        for item in patterns:
            args.extend(["--exclude", item])
        args.extend([f"{source.as_posix().rstrip('/')}/", f"{target.as_posix().rstrip('/')}/"])
        result = subprocess.run(args)
        if result.returncode != 0:
            raise RuntimeError(f"rsync failed for {source} -> {target} with exit code {result.returncode}")
        return

    shutil.copytree(source, target, dirs_exist_ok=True)


def dump_immich_database(destination: Path) -> None:
    destination.parent.mkdir(parents=True, exist_ok=True)
    log.info("[*] Exporting Immich database...")
    with subprocess.Popen(
        ["docker", "exec", "immich-postgres", "pg_dumpall", "-c", "-U", "postgres"],
        stdout=subprocess.PIPE,
        stderr=subprocess.DEVNULL,
        cwd=str(ROOT),
    ) as process:
        if process.stdout is None:
            raise RuntimeError("Unable to capture Immich database dump output")
        with gzip.open(destination, "wb") as handle:
            shutil.copyfileobj(process.stdout, handle)
        returncode = process.wait()

    if returncode != 0:
        raise RuntimeError(f"Immich database dump failed with exit code {returncode}")

    if destination.stat().st_size == 0:
        raise RuntimeError("Immich database dump is empty")


def stop_services() -> None:
    log.info("[*] Stopping all containers...")
    run_command(["make", "down"], cwd=ROOT)


def start_services() -> None:
    log.info("[*] Ensuring containers are UP...")
    run_command(["make", "up"], cwd=ROOT)


def cleanup_old_backups(dest: Path) -> None:
    backup_dirs = sorted(
        (entry for entry in dest.iterdir() if entry.is_dir() and is_timestamp_dir(entry.name)),
        key=lambda entry: entry.stat().st_mtime,
        reverse=True,
    )
    for old_dir in backup_dirs[BACKUP_RETENTION:]:
        log.info("  Removing: %s", old_dir)
        shutil.rmtree(old_dir, ignore_errors=True)


def main() -> None:
    log.info("=== Homelab Backup Started ===")

    env = load_env(ENV_FILE)
    backup_dest = env.get("BACKUP_DIR", "").strip()
    media_root = env.get("MEDIA_DIR", "").strip()

    if not backup_dest:
        log.error("[ERROR] BACKUP_DIR missing in .env")
        sys.exit(1)
    if not media_root:
        log.error("[ERROR] MEDIA_DIR missing in .env")
        sys.exit(1)

    backup_root = Path(backup_dest).expanduser()
    backup_root.mkdir(parents=True, exist_ok=True)

    media_src = Path(media_root).expanduser()
    if not media_src.exists():
        log.error("[ERROR] MEDIA_DIR (%s) does not exist", media_src)
        sys.exit(1)

    timestamp = datetime.now(tz=timezone.utc).strftime("%Y-%m-%d_%H%M%S")
    backup_dir = backup_root / timestamp
    config_dir = backup_dir / "config"
    media_dir = backup_dir / "media"
    config_dir.mkdir(parents=True, exist_ok=True)
    media_dir.mkdir(parents=True, exist_ok=True)

    log.info("[*] Destination: %s", backup_dir)

    try:
        dump_immich_database(config_dir / "immich_db_dump.sql.gz")

        log.info("[*] Copying .env...")
        shutil.copy2(ENV_FILE, config_dir / ".env")

        stop_services()

        log.info("[*] Syncing Homelab config...")
        sync_tree(ROOT, config_dir / "homelab", CONFIG_EXCLUDES + CONFIG_FILE_EXCLUDES)

        for source_name in MEDIA_SOURCES:
            source = media_src / source_name
            if not source.exists():
                raise RuntimeError(f"Media source missing: {source}")
            log.info("[*] Syncing %s media...", source_name)
            sync_tree(source, media_dir / source_name, [])

        cleanup_old_backups(backup_root)
        log.info("=== Backup Completed Successfully ===")
    except Exception as exc:
        log.error("[ERROR] %s", exc)
        shutil.rmtree(backup_dir, ignore_errors=True)
        sys.exit(1)
    finally:
        try:
            start_services()
        except Exception as exc:
            log.error("[FATAL] %s", exc)
            sys.exit(1)


if __name__ == "__main__":
    main()