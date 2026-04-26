#!/usr/bin/env bash
set -euo pipefail

BASE_DIR="$HOME/apps/sys"
EXT_DIR="/run/extensions"
PACMAN_DB="/var/lib/pacman"
# Temporary bridge to isolate Btrfs subvolumes
SOURCE_BRIDGE="/run/sysext_source_bridge"

echo "=== systemd-sysext Btrfs-Safe Toggle ==="

# ---------- Helpers ----------
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

cleanup_btrfs_bridge() {
  if mountpoint -q "$SOURCE_BRIDGE"; then
    echo "Cleaning up Btrfs source bridge..."
    sudo umount "$SOURCE_BRIDGE"
  fi
  sudo rm -rf "$SOURCE_BRIDGE"
}

# ---------- Execution ----------

# Build list of extension directories
mapfile -t EXT_PATHS < <(find "$BASE_DIR" -mindepth 1 -maxdepth 1 -type d | sort)

if [[ ${#EXT_PATHS[@]} -eq 0 ]]; then
  echo "No extension directories found in $BASE_DIR"
  exit 1
fi

EXT_LIST=()
for path in "${EXT_PATHS[@]}"; do
  EXT_LIST+=("$(basename "$path")")
done

SYSEXT_STATUS="$(systemd-sysext status 2>/dev/null || echo "none")"

# --- GLOBAL UNMERGE ---
for ext in "${EXT_LIST[@]}"; do
  if grep -qw "$ext" <<< "$SYSEXT_STATUS"; then
    echo "$ext overlay is active. Unmerging..."
    sudo systemd-sysext unmerge
    unlock_pacman_db
    cleanup_btrfs_bridge
    exit 0
  fi
done

# --- INTERACTIVE PICKER ---
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

# 1. Prepare Bridges and Directories
sudo mkdir -p "$EXT_DIR"
sudo mkdir -p "$SOURCE_BRIDGE"

# 2. THE FIX: Bind mount extension to /run to bypass Btrfs subvolume boundaries
echo "Bridging $TARGET_NAME to /run..."
sudo mount --bind "$TARGET_DIR" "$SOURCE_BRIDGE"

# 3. Symlink from the bridge, not from $HOME
echo "Cleaning old links and creating new bridge link..."
sudo find "$EXT_DIR" -maxdepth 1 -type l -delete
sudo ln -sfn "$SOURCE_BRIDGE" "$EXT_DIR/$TARGET_NAME"

# 4. Merge
echo "Merging extension..."
sudo systemd-sysext refresh

# 5. Lock DB
lock_pacman_db

echo "Done. Your /home should remain Read-Write."
