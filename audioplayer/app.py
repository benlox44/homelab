import json
import glob
import os
import re
import tempfile
import shutil
import subprocess
import logging
from decimal import Decimal, InvalidOperation
from urllib.parse import unquote
from flask import Flask, request, jsonify, render_template, send_from_directory, abort
from werkzeug.utils import secure_filename
from mutagen.mp3 import MP3
from mutagen import MutagenError
from yt_dlp import YoutubeDL
from yt_dlp.utils import DownloadError

app = Flask(__name__)
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# Temporary upload staging area and permanent mod-managed library.
UPLOAD_DIR = "/data/audioplayer_uploads"
PERMANENT_DIR = "/data/world/audio_player_data"
META_FILE = os.path.join(PERMANENT_DIR, "meta.json")

# Limits
MAX_DURATION_SECONDS = 500
MAX_UPLOAD_BYTES = 60 * 1024 * 1024  # 60 MB safety cap on upload size

app.config["MAX_CONTENT_LENGTH"] = MAX_UPLOAD_BYTES

os.makedirs(UPLOAD_DIR, exist_ok=True)
os.makedirs(PERMANENT_DIR, exist_ok=True)


def clean_name(name: str) -> str:
    """Turn user-provided name into a safe filename stem (no extension)."""
    name = name.strip()
    name = os.path.splitext(name)[0]  # drop any extension the user typed
    name = secure_filename(name)
    name = re.sub(r"[^A-Za-z0-9_\-]", "", name)
    return name


def parse_timestamp(value: str | None):
    if value is None or str(value).strip() == "":
        return None

    value = str(value).strip()

    try:
        if ":" in value:
            parts = value.split(":")
            total = Decimal("0")
            for part in parts:
                total = total * 60 + Decimal(part)
            return float(total)
        return float(Decimal(value))
    except (InvalidOperation, ValueError):
        return None


def validate_range(start_seconds, end_seconds):
    if start_seconds is not None and start_seconds < 0:
        return "Start time cannot be negative."
    if end_seconds is not None and end_seconds <= 0:
        return "End time must be greater than 0."
    if start_seconds is not None and end_seconds is not None and end_seconds <= start_seconds:
        return "End time must be greater than start time."
    return None


def run_ffmpeg_trim(source_path: str, output_path: str, start_seconds=None, end_seconds=None):
    ffmpeg_command = ["ffmpeg", "-y"]
    if start_seconds is not None:
        ffmpeg_command.extend(["-ss", str(start_seconds)])
    ffmpeg_command.extend(["-i", source_path])
    if end_seconds is not None:
        ffmpeg_command.extend(["-to", str(end_seconds)])
    ffmpeg_command.extend(["-vn", "-codec:a", "libmp3lame", "-q:a", "4", output_path])

    subprocess.run(ffmpeg_command, check=True, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)


def finalize_audio(source_path: str, final_path: str, start_seconds=None, end_seconds=None):
    temp_cut_path = None

    try:
        if start_seconds is not None or end_seconds is not None:
            with tempfile.NamedTemporaryFile(dir=UPLOAD_DIR, suffix=".mp3", delete=False) as temp_cut_handle:
                temp_cut_path = temp_cut_handle.name

            run_ffmpeg_trim(source_path, temp_cut_path, start_seconds, end_seconds)
            os.replace(temp_cut_path, final_path)
        else:
            os.replace(source_path, final_path)

        os.chmod(final_path, 0o644)
    finally:
        if temp_cut_path and os.path.exists(temp_cut_path):
            os.remove(temp_cut_path)


def download_youtube_audio(url: str, download_root: str):
    format_selectors = [
        "bestaudio[ext=m4a]/bestaudio/best",
        "best",
        "worstvideo+bestaudio/best",
    ]
    last_error = None

    for format_selector in format_selectors:
        logger.info(f"Trying yt-dlp format selector: {format_selector}")
        ydl_options = {
            "format": format_selector,
            "outtmpl": os.path.join(download_root, "%(id)s.%(ext)s"),
            "noplaylist": True,
            "quiet": False,
            "no_warnings": False,
            "socket_timeout": 30,
            "postprocessors": [{
                "key": "FFmpegExtractAudio",
                "preferredcodec": "mp3",
                "preferredquality": "192",
            }],
        }

        try:
            with YoutubeDL(ydl_options) as ydl:
                logger.info(f"Starting download with format: {format_selector}")
                return ydl.extract_info(url, download=True)
        except DownloadError as exc:
            last_error = exc
            message = str(exc).lower()
            logger.warning(f"Format '{format_selector}' failed with error: {exc}")
            if "only images" in message:
                logger.error(f"Video contains only images, no audio/video available")
                raise RuntimeError("This video contains only images and cannot be downloaded as audio.")
            if "requested format" not in message or "not available" not in message:
                logger.error(f"Non-recoverable download error: {exc}")
                raise
            logger.info(f"Format unavailable, trying next option...")

    if last_error is not None:
        logger.error(f"All format selectors exhausted. Last error: {last_error}")
        error_msg = str(last_error)
        if "only images" in error_msg:
            raise RuntimeError("This video contains only images and cannot be downloaded as audio.")
        raise last_error

    raise RuntimeError("YouTube download failed before any format could be selected.")


@app.route("/")
def index():
    return render_template("index.html")


@app.route("/temporary-files")
def list_temporary_files():
    files = sorted(f for f in os.listdir(UPLOAD_DIR) if f.lower().endswith(".mp3"))
    return jsonify(files)


@app.route("/files")
def list_files():
    return list_temporary_files()


def load_permanent_entries():
    if not os.path.isfile(META_FILE):
        return []

    try:
        with open(META_FILE, "r", encoding="utf-8") as meta_handle:
            meta = json.load(meta_handle)
    except (OSError, json.JSONDecodeError):
        return []

    files = meta.get("files", {})
    entries = []

    for file_id, info in files.items():
        safe_id = secure_filename(file_id)
        if safe_id != file_id:
            continue

        file_name = unquote(str(info.get("fileName", safe_id)))
        owner = info.get("owner") or {}
        owner_name = owner.get("name", "")
        owner_uuid = owner.get("uuid", "")
        created = info.get("created")
        audio_path = os.path.join(PERMANENT_DIR, safe_id)
        alt_audio_path = os.path.join(PERMANENT_DIR, f"{safe_id}.mp3")

        entries.append({
            "id": safe_id,
            "fileName": file_name,
            "created": created,
            "ownerName": owner_name,
            "ownerUuid": owner_uuid,
            "exists": os.path.isfile(audio_path) or os.path.isfile(alt_audio_path),
        })

    entries.sort(key=lambda item: item["fileName"].lower())
    return entries


@app.route("/permanent-files")
def list_permanent_files():
    return jsonify(load_permanent_entries())


@app.route("/audio/<path:filename>")
def serve_audio(filename):
    safe = secure_filename(filename)
    if safe != filename or not safe.lower().endswith(".mp3"):
        abort(404)
    full_path = os.path.join(UPLOAD_DIR, safe)
    if not os.path.isfile(full_path):
        abort(404)
    return send_from_directory(UPLOAD_DIR, safe, mimetype="audio/mpeg")


@app.route("/permanent-audio/<path:filename>")
def serve_permanent_audio(filename):
    safe = secure_filename(filename)
    if safe != filename:
        abort(404)

    candidates = [os.path.join(PERMANENT_DIR, safe), os.path.join(PERMANENT_DIR, f"{safe}.mp3")]
    full_path = next((candidate for candidate in candidates if os.path.isfile(candidate)), None)
    if full_path is None:
        abort(404)

    return send_from_directory(PERMANENT_DIR, os.path.basename(full_path), mimetype="audio/mpeg")


@app.route("/upload", methods=["POST"])
def upload():
    if "file" not in request.files:
        return jsonify({"error": "No file provided."}), 400

    upload_file = request.files["file"]
    desired_name = request.form.get("newname", "")

    if upload_file.filename == "":
        return jsonify({"error": "No file selected."}), 400

    if not upload_file.filename.lower().endswith(".mp3"):
        return jsonify({"error": "Only .mp3 files are allowed."}), 400

    stem = clean_name(desired_name)
    if not stem:
        return jsonify({"error": "Please enter a valid new file name."}), 400

    final_name = f"{stem}.mp3"
    final_path = os.path.join(UPLOAD_DIR, final_name)

    if os.path.exists(final_path):
        return jsonify({"error": f"A file named '{final_name}' already exists. Choose a different name."}), 409

    # Save to a temp file in the target directory so the final move stays on one filesystem.
    with tempfile.NamedTemporaryFile(dir=UPLOAD_DIR, suffix=".mp3", delete=False) as tmp:
        tmp_path = tmp.name
        upload_file.save(tmp_path)

    try:
        try:
            audio = MP3(tmp_path)
            duration = audio.info.length
        except MutagenError:
            os.remove(tmp_path)
            return jsonify({"error": "Could not read this file as a valid MP3."}), 400

        if duration > MAX_DURATION_SECONDS:
            os.remove(tmp_path)
            return jsonify({
                "error": f"Audio is {duration:.0f}s long, which exceeds the {MAX_DURATION_SECONDS}s limit."
            }), 400

        finalize_audio(tmp_path, final_path)
    except Exception as e:
        if os.path.exists(tmp_path):
            os.remove(tmp_path)
        return jsonify({"error": f"Unexpected error: {e}"}), 500

    return jsonify({
        "message": "Upload successful.",
        "filename": final_name,
        "duration": round(duration, 1),
        "command": f"/audioplayer serverfile {final_name}"
    })


@app.route("/youtube", methods=["POST"])
def import_youtube():
    data = request.get_json(silent=True) or {}
    url = (data.get("url") or "").strip()
    desired_name = (data.get("newname") or "").strip()
    start_seconds = parse_timestamp(data.get("start"))
    end_seconds = parse_timestamp(data.get("end"))

    if not url:
        return jsonify({"error": "Please paste a YouTube link."}), 400

    if "youtube.com" not in url and "youtu.be" not in url:
        return jsonify({"error": "That does not look like a YouTube link."}), 400

    range_error = validate_range(start_seconds, end_seconds)
    if range_error:
        return jsonify({"error": range_error}), 400

    if not desired_name:
        desired_name = "youtube_import"

    stem = clean_name(desired_name)
    if not stem:
        return jsonify({"error": "Please enter a valid file name."}), 400

    final_name = f"{stem}.mp3"
    final_path = os.path.join(UPLOAD_DIR, final_name)

    if os.path.exists(final_path):
        return jsonify({"error": f"A file named '{final_name}' already exists. Choose a different name."}), 409

    download_root = tempfile.mkdtemp(dir=UPLOAD_DIR)

    try:
        info = download_youtube_audio(url, download_root)

        mp3_candidates = glob.glob(os.path.join(download_root, "*.mp3"))
        if not mp3_candidates:
            raise RuntimeError("YouTube download did not produce an MP3 file.")

        downloaded_path = mp3_candidates[0]

        if not os.path.isfile(downloaded_path):
            return jsonify({"error": "YouTube download failed before conversion finished."}), 500

        try:
            audio = MP3(downloaded_path)
            duration = audio.info.length
        except MutagenError:
            if os.path.exists(downloaded_path):
                os.remove(downloaded_path)
            return jsonify({"error": "Downloaded audio could not be read as MP3."}), 400

        if duration > MAX_DURATION_SECONDS:
            if os.path.exists(downloaded_path):
                os.remove(downloaded_path)
            return jsonify({"error": f"Audio is {duration:.0f}s long, which exceeds the {MAX_DURATION_SECONDS}s limit."}), 400

        finalize_audio(downloaded_path, final_path, start_seconds, end_seconds)
        return jsonify({
            "message": "YouTube import successful.",
            "filename": final_name,
            "duration": round(duration, 1),
            "command": f"/audioplayer serverfile {final_name}"
        })
    except Exception as e:
        return jsonify({"error": f"Unexpected error: {e}"}), 500
    finally:
        shutil.rmtree(download_root, ignore_errors=True)


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)
