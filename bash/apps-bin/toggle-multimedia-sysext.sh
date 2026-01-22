#!/usr/bin/env bash

# Prepare extensions directory
# Prepare multimedia symlink
if [[ ! -d /run/extensions ]]; then
  echo "Creating /run/extensions..."
  sudo mkdir -p /run/extensions
  sudo ln -s "/home/noodle/apps/pac/multimedia/" /run/extensions/multimedia
else
  echo "/run/extensions already exists, skipping."
fi

# Toggle systemd-sysext overlay
if systemd-sysext | grep -q 'multimedia'; then
  echo "Multimedia overlay is merged. Unmerging..."
  sudo systemd-sysext unmerge
else
  echo "Multimedia overlay is not merged. Merging..."
  #sudo systemd-sysext merge
  sudo systemd-sysext refresh
fi

