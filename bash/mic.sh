#!/usr/bin/env bash

set -euo pipefail

# --------------------------------------------------
# Helper: ask user to select a valid PulseAudio item
# --------------------------------------------------
select_device() {
  local TYPE="$1"   # sinks | sources
  local LABEL="$2"  # Speaker | Microphone

  while true; do
    echo ""
    echo "--- Available Audio ${LABEL}s ---"

    # Show compact list
    pactl list "${TYPE}" short | awk '{printf "[%s] %s\n", $1, $2}'

    echo ""
    read -rp "Enter the INDEX of the ${LABEL} you want to use: " INPUT_ID

    # Check empty input
    if [[ -z "${INPUT_ID// }" ]]; then
      echo "Error: Input cannot be empty."
      continue
    fi

    # Check numeric input
    if ! [[ "$INPUT_ID" =~ ^[0-9]+$ ]]; then
      echo "Error: Please enter a valid numeric index."
      continue
    fi

    # Find matching device
    DEVICE_NAME=$(pactl list "${TYPE}" short | awk -v id="$INPUT_ID" '$1==id {print $2}')

    # Validate existence
    if [[ -z "$DEVICE_NAME" ]]; then
      echo "Error: Index '$INPUT_ID' is out of range."
      continue
    fi

    # Return values
    SELECTED_ID="$INPUT_ID"
    SELECTED_NAME="$DEVICE_NAME"
    return 0
  done
}

# --------------------------------------------------
# Select Sink (Speaker)
# --------------------------------------------------
select_device "sinks" "Speaker"
SINK_ID="$SELECTED_ID"
SINK_NAME="$SELECTED_NAME"

# --------------------------------------------------
# Select Source (Microphone)
# --------------------------------------------------
select_device "sources" "Microphone"
SOURCE_ID="$SELECTED_ID"
SOURCE_NAME="$SELECTED_NAME"

echo ""
echo "----------------------------------------"
echo "Selected Devices"
echo "----------------------------------------"
echo "Speaker [$SINK_ID]: $SINK_NAME"
echo "Mic     [$SOURCE_ID]: $SOURCE_NAME"
echo ""

# --------------------------------------------------
# Apply echo cancellation
# --------------------------------------------------
echo "Applying Echo Cancellation..."

MODULE_ID=$(
  pactl load-module module-echo-cancel \
    source_master="$SOURCE_NAME" \
    sink_master="$SINK_NAME" \
    aec_method=webrtc \
    source_properties=device.description=Echo-Cancel_Mic
  )

  echo ""
  echo "Success!"
  echo "Loaded module ID: $MODULE_ID"
  echo ""
  echo "Now open your Sound Settings and select:"
  echo "  Echo-Cancel_Mic"
  echo "as your input device."
