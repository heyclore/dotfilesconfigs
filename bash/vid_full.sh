rm screen.mp4
ffmpeg -f x11grab -framerate 20 -i $DISPLAY screen.mp4
