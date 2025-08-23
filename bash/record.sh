pactl load-module module-null-sink sink_name=combined sink_properties=device.description=CombinedSink
pactl load-module module-loopback source=alsa_input.pci-0000_03_00.6.analog-stereo sink=combined
pactl load-module module-loopback source=alsa_output.pci-0000_03_00.6.analog-stereo.monitor sink=combined

#ffmpeg -y \
#  -f pulse -i alsa_output.pci-0000_03_00.6.analog-stereo.monitor \
#  -f pulse -i alsa_input.pci-0000_03_00.6.analog-stereo \
#  -filter_complex "[1:a]afftdn=nf=-20,highpass=f=200,lowpass=f=3000,volume=2.0[aud1]; [0:a][aud1]amix=inputs=2:duration=longest[aud2]" \
#  -map "[aud2]" \
#  -ar 16000 \
#  -ac 1 \
#  /tmp/output.wav


# Set the value of foo
foo=1  # or foo=1 depending on your requirement

# Common part of the ffmpeg command including -ar and -ac
common_ffmpeg_cmd="ffmpeg -y \
  -f pulse -i alsa_output.pci-0000_03_00.6.analog-stereo.monitor \
  -ar 16000 \
  -ac 1"

if [ $foo -eq 0 ]; then
    # Full ffmpeg command for foo=0
    full_ffmpeg_cmd="$common_ffmpeg_cmd \
      -f pulse -i alsa_input.pci-0000_03_00.6.analog-stereo \
      -filter_complex \"[1:a]afftdn=nf=-20,highpass=f=200,lowpass=f=3000,volume=2.0[aud1]; [0:a][aud1]amix=inputs=2:duration=longest[aud2]\" \
      -map \"[aud2]\" \
      /tmp/output.wav"
elif [ $foo -eq 1 ]; then
  full_ffmpeg_cmd="ffmpeg -y \
    -f x11grab -framerate 20 -video_size 1680x1050 -ac 1 -i \"$DISPLAY\" -f pulse -ar 16000 -i alsa_output.pci-0000_03_00.6.analog-stereo.monitor /tmp/screen.mp4"
elif [ $foo -eq 2 ]; then
    # Reduced ffmpeg command for foo=1
    full_ffmpeg_cmd="$common_ffmpeg_cmd \
      /tmp/output.wav"
else
    echo "Invalid value of foo. Expected 0 or 1."
    exit 1
fi

# Execute the constructed ffmpeg command
eval "$full_ffmpeg_cmd"


##!/bin/bash
## List of options
#options="foo\nbar\nbaz\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n"
#
## Get the active window ID
#active_window_id=$(xprop -root _NET_ACTIVE_WINDOW | awk '{print $5}')
#
## Number of lines to display in dmenu
#num_lines=14
#
## Use dmenu to select an option and store the selection in the variable 'foo'
#foo=$(echo -e "$options" | dmenu -i -p "Select an option:" -l "$num_lines" -w "$active_window_id")
#
## Check if 'foo' is not empty
#if [ -n "$foo" ]; then
#    # Do something with the selected option stored in 'foo'
#    echo "You selected: $foo"
#else
#    echo "No option selected."
#fi
#
#
##!/bin/bash
#foo=("foo" "bar" "baz")
#
#x="bar"
#
#if [ "$x" == "${foo[0]}" ]; then
#    echo 11
#elif [ "$x" == "${foo[1]}" ]; then
#    echo 22
#elif [ "$x" == "${foo[2]}" ]; then
#    echo 33
#else
#    echo 44
#fi
#
