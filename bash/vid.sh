rm screen.mp4
ffmpeg -f x11grab -framerate 20 -video_size 1680x1050 -i $DISPLAY screen.mp4
