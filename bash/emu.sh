#emulator -avd Nexus_S_API_32 -dns-server 8.8.8.8 -camera-front none -camera-back none -gpu auto -memory 1024 -noaudio -no-boot-anim
#emulator -avd Nexus_S_API_32 -camera none -gps none -no-snapshot-load -no-snapshot-save -sensors none -no-accel -no-audio -no-boot-anim -no-window
#emulator -avd Nexus_S_API_32 -dns-server 8.8.8.8 -camera-front none -camera-back none -gpu host -memory 1024 -noaudio -no-boot-anim
#emulator -avd Nexus_S_API_32 -dns-server 8.8.8.8 -camera-front none -camera-back none -gpu host -noaudio
#emulator -avd Nexus_S_API_32 -dns-server 8.8.8.8 -camera-front none -camera-back none -noaudio
#emulator -avd 10.1_WXGA_Tablet_API_32 -dns-server 8.8.8.8 -camera-front none -camera-back none -noaudio



#AVD_NAME="Nexus_S_API_32"
#AVD_NAME="10.1_WXGA_Tablet_API_32"
AVD_NAME="a32"

CPU_CORES=2
CAMERA=false
DNS=true
GPU=true
ANIM=false
AUDIO=false
SNAPSHOT_SAVE=false

EMULATOR_CMD="emulator -avd $AVD_NAME -cores $CPU_CORES"

if [[ $CAMERA == true ]]; then
  EMULATOR_CMD+=" -camera webcam0"
else
  EMULATOR_CMD+=" -camera-front none -camera-back none"
fi

if [[ $DNS == true ]]; then
  EMULATOR_CMD+=" -dns-server 8.8.8.8"
else
  EMULATOR_CMD+=""
fi

if [[ $GPU == true ]]; then
  EMULATOR_CMD+=" -gpu host"
else
  EMULATOR_CMD+=""
fi

if [[ $ANIM == true ]]; then
  EMULATOR_CMD+=""
else
  EMULATOR_CMD+=" -no-boot-anim"
fi

if [[ $AUDIO == true ]]; then
  EMULATOR_CMD+=""
else
  EMULATOR_CMD+=" -noaudio"
fi

if [[ $SNAPSHOT_SAVE == true ]]; then
  EMULATOR_CMD+=""
else
  EMULATOR_CMD+=" -no-snapshot-save"
fi

echo $EMULATOR_CMD

$EMULATOR_CMD
