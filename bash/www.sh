xhost +local:
bwrap \
  --bind ~/containers/compiler / \
  --dev /dev \
  --proc /proc \
  --ro-bind /etc/resolv.conf /etc/resolv.conf \
  --ro-bind /tmp/.X11-unix/X1 /tmp/.X11-unix/X1 \
  --setenv $DISPLAY \
  --unshare-net \
  --unshare-pid \
  --unshare-ipc \
  --unshare-uts \
  --die-with-parent \
  --tmpfs /run \
  /bin/gimp

