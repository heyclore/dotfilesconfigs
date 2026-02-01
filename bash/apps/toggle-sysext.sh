#!/usr/bin/env bash
set -euo pipefail

BASE_DIR="/home/noodle/apps/sys"
EXT_DIR="/run/extensions"

echo "=== systemd-sysext toggle ==="

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

echo "Done."

