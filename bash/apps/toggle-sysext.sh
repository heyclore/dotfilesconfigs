#!/usr/bin/env bash
set -euo pipefail

BASE_DIR="/home/noodle/apps/sys"
EXT_DIR="/run/extensions"
PACMAN_DB="/var/lib/pacman"

echo "=== systemd-sysext toggle ==="

# ---------- pacman DB helpers ----------
lock_pacman_db() {
  if ! mount | grep -q "on $PACMAN_DB "; then
    echo "Bind-mounting pacman DB..."
    sudo mount --bind "$PACMAN_DB" "$PACMAN_DB"
  fi

  if ! mount | grep -q "on $PACMAN_DB .* ro,"; then
    echo "Locking pacman DB (read-only)..."
    sudo mount -o remount,ro "$PACMAN_DB"
  fi
}

unlock_pacman_db() {
  if mount | grep -q "on $PACMAN_DB "; then
    echo "Unlocking pacman DB (read-write)..."
    sudo mount -o remount,rw "$PACMAN_DB"
    sudo umount "$PACMAN_DB"
  fi
}

# Build list of extension directories
mapfile -t EXT_PATHS < <(find "$BASE_DIR" -mindepth 1 -maxdepth 1 -type d | sort)

if [[ ${#EXT_PATHS[@]} -eq 0 ]]; then
  echo "No extension directories found in $BASE_DIR"
  exit 1
fi

# Extract just names
EXT_LIST=()
for path in "${EXT_PATHS[@]}"; do
  EXT_LIST+=("$(basename "$path")")
done

# Get sysext status once
SYSEXT_STATUS="$(systemd-sysext status)"

# --- GLOBAL SHORT-CIRCUIT: If any known extension is merged, unmerge ---
for ext in "${EXT_LIST[@]}"; do
  if grep -qw "$ext" <<< "$SYSEXT_STATUS"; then
    echo "$ext overlay is merged. Unmerging..."
    sudo systemd-sysext unmerge
    unlock_pacman_db
    exit 0
  fi
done

# -------- INTERACTIVE PICKER --------
echo "Available extensions:"
select TARGET_NAME in "${EXT_LIST[@]}"; do
  if [[ -n "$TARGET_NAME" ]]; then
    TARGET_DIR="$BASE_DIR/$TARGET_NAME"
    break
  else
    echo "Invalid selection."
  fi
done

echo "Selected extension: $TARGET_NAME"

# Prepare extensions directory
if [[ ! -d "$EXT_DIR" ]]; then
  echo "Creating $EXT_DIR..."
  sudo mkdir -p "$EXT_DIR"
fi

# Remove old symlinks (only one active extension)
echo "Cleaning old extension links..."
sudo find "$EXT_DIR" -maxdepth 1 -type l -delete

# Create symlink
echo "Linking $TARGET_NAME → $EXT_DIR"
sudo ln -sfn "$TARGET_DIR" "$EXT_DIR/$TARGET_NAME"

# Merge extension
echo "Merging $TARGET_NAME overlay..."
sudo systemd-sysext refresh

# Lock pacman DB BEFORE merging sysext
lock_pacman_db

echo "Done."

