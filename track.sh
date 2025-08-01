#!/bin/bash

LOG_FILE="$HOME/.work_log.txt"
DATE=$(date +"%Y-%m-%d")
TIME=$(date +"%H:%M:%S")

case "$1" in
  "resume")
    echo "$DATE,$TIME,resume" >> "$LOG_FILE"
    echo "Work resumed at $TIME"
    ;;

  "pause")
    echo "$DATE,$TIME,pause" >> "$LOG_FILE"
    echo "Work paused at $TIME"
    ;;

  "newday")
    echo "--- NEW DAY ---" >> "$LOG_FILE"
    echo "New day started!"
    ;;

  "calculate")
    awk -F, '
    function to_epoch(date, time,   cmd) {
      cmd = "date -j -f \"%Y-%m-%d %H:%M:%S\" \"" date " " time "\" +%s"
      cmd | getline result
      close(cmd)
      return result
    }

    BEGIN {
      work = 0
      breaktime = 0
      prev_time = 0
      prev_state = ""
    }

    /^---/ { next }

    {
      cur_time = to_epoch($1, $2)
      if (prev_time > 0) {
        delta = cur_time - prev_time
        if (prev_state == "resume") {
          work += delta
        } else if (prev_state == "pause") {
          breaktime += delta
        }
      }
      prev_time = cur_time
      prev_state = $3
    }

    END {
      printf "Total work time: %.2f hours\n", work / 3600
      printf "Total break time: %.2f hours\n", breaktime / 3600
    }
    ' "$LOG_FILE"
    ;;

  *)
    echo "Usage: ./track.sh resume | pause | calculate | newday"
    ;;
esac

