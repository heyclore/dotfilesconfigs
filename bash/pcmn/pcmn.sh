#!/usr/bin/env bash
set -euo pipefail

if [[ $# -ne 1 ]]; then
  echo "Usage: $0 <bundle-file>"
  exit 1
fi

bundle_file="$1"

target_tmp_dir="/tmp/tmp"
#target_pkg_dir="$HOME/apps/pac"
target_pkg_dir="/tmp/foo"

declare -a packages
current=""
bundle_name=""

# --- Parse bundle file ---
while IFS= read -r line || [[ -n $line ]]; do
  if [[ $line == %*% ]]; then
    current="${line:1:-1}"
    continue
  fi

  if [[ $current == "PACKAGES" && -n $line ]]; then
    packages+=("$line")
  fi

  if [[ $current == "NAME" ]]; then
    if [[ -z "$bundle_name" ]]; then
      bundle_name="$line"
    fi
  fi
done < "$bundle_file"

if ((${#packages[@]} == 0)); then
  echo "No packages found in $bundle_file"
  exit 1
fi

echo "Bundle packages:"
echo "${packages[@]}"

# Ensure we're not in the directory we might delete
cd ~

# --- Prepare directories ---
sudo rm -rf "$target_tmp_dir/"
mkdir -p "$target_tmp_dir/${bundle_name}/usr/lib/extension-release.d"
echo "ID=arch" > "$target_tmp_dir/${bundle_name}/usr/lib/extension-release.d/extension-release.${bundle_name}"
#  mkdir -p "$target_pkg_dir"

# --- Download packages ---
if ! sudo pacman \
  --downloadonly \
  --cachedir="$target_tmp_dir/" \
  -Sw \
  "${packages[@]}"
then
  echo "Failed to download one or more packages"
  exit 1
fi

for f in "$target_tmp_dir"/*.pkg.tar.zst; do
  [[ -e "$f" ]] || continue  # skip if no matches
  echo "Extracting: $f"
  tar -xvf "$f" -C "$target_tmp_dir/${bundle_name}"
done


# --- Store packages locally ---
#cp -v "$target_tmp_dir/pkg/"*.pkg.tar.* "$target_pkg_dir/"

