ffmpeg -f x11grab -video_size 1680x1050 -i $DISPLAY -vframes 1 `date "+%s.png"`
