if systemd-sysext | grep 'multimedia'; then
  echo "Multimedia overlay is merged. Unmerging..."
  sudo systemd-sysext unmerge
else
  echo "Multimedia overlay is not merged. Merging..."
  sudo systemd-sysext merge
fi

