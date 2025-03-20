xhost +local:
#export DBUS_SESSION_BUS_ADDRESS=unix:path=/run/dbus/system_bus_socket
#sudo systemd-nspawn --bind /run/dbus:/run/dbus --bind /tmp/.X11-unix:/tmp/.X11-unix -D ~/winedoews/
#--bind=/tmp/.X11-unix \
#--setenv=DISPLAY=$DISPLAY \
#--as-pid2 \

sudo systemd-nspawn \
  --as-pid2 \
  --directory=winedoews \
  --user=noodle \
  --setenv=DISPLAY=:1 \
  --setenv=XAUTHORITY=$XAUTHORITY \
  --bind=/home/noodle/actions \
  --bind=/dev/dri \
  --bind=/dev/snd \
  --bind=/dev/bus/ \
  --bind=/run/dbus \
  --bind=/tmp/.X11-unix:/tmp/.X11-unix \
  --property='DeviceAllow=char-alsa rwm' \
  --property='DeviceAllow=char-drm rwm' \
  --bind=/run/dbus/system_bus_socket:/run/dbus/system_bus_socket
