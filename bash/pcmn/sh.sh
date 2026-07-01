#!/usr/bin/env bash
set -euo pipefail

target_tmp_dir="/tmp/tmp"
cache_dir="$target_tmp_dir/cache"

# ----------------------------
# Bundle definitions
# ----------------------------
foo_packages=(
  make
)

extra_packages=(
  btop
  less
  nvtop
  tmux
  tree
  unclutter
  unzip
  wget
  which
  xclip
  xdg-utils
  xorg-xev
  xorg-xhost
  xorg-xkill
  xorg-xprop
  xorg-xsetroot
  vifm
  chafa
  man
  alsa-utils
  lxappearance
  patchelf
  pkgfile
  mpv
  pacman-contrib
)

# ----------------------------
# Helpers
# ----------------------------
collect_packages() {
  sudo pacman -Sp --print-format '%n' "$@" | sort -u
}

subtract_arrays() {
  local -n base_ref=$1
  local -n target_ref=$2
  declare -A seen
  local pkg

  for pkg in "${base_ref[@]}"; do
    seen["$pkg"]=1
  done

  for pkg in "${target_ref[@]}"; do
    [[ -n "${seen[$pkg]:-}" ]] && continue
    echo "$pkg"
  done
}

# ----------------------------
# Choose bundle
# ----------------------------
read -rp "Choose bundle (foo/extra): " bundle_name
declare -a packages=()

case "$bundle_name" in
  foo)
    mapfile -t packages < <(collect_packages "${foo_packages[@]}")
    ;;
  extra)
    mapfile -t foo_resolved < <(collect_packages "${foo_packages[@]}")
    mapfile -t extra_resolved < <(collect_packages "${extra_packages[@]}")
    mapfile -t packages < <(subtract_arrays foo_resolved extra_resolved)
    ;;
  *)
    echo "Invalid bundle"
    exit 1
    ;;
esac

# ----------------------------
# Prepare dirs
# ----------------------------
sudo rm -rf "$target_tmp_dir"
mkdir -p "$cache_dir"
mkdir -p "$target_tmp_dir/$bundle_name"

# ----------------------------
# Download packages
# ----------------------------
sudo pacman \
  --cachedir="$cache_dir" \
  -Sddw \
  "${packages[@]}"

# ----------------------------
# Extract packages
# ----------------------------
for f in "$cache_dir"/*.pkg.tar.*; do
  [[ "$f" == *.sig ]] && continue
  echo "Extracting: $f"
  tar -xvf "$f" -C "$target_tmp_dir/$bundle_name"
done
