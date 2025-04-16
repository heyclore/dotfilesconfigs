#!/bin/bash

# Loop through standard foreground colors (30–37)
for i in {0..108}; do
  # Skip numbers between 50 and 88
  if [[ $i -ge 50 && $i -le 88 ]]; then
    continue
  fi

  # Calculate bright color (i + 60)
  bright=$((i + 60))

  # Print the standard color and the bright color
  echo -e "\033[${i}m${i}\t\t\033[${bright}m${bright}"
done

