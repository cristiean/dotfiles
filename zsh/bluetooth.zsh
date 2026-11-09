# Bluetooth helpers: airpods and keyboard commands, and the bt_* functions they
# use. Sourced by .zshrc, and by the menu bar app in ~/.config/menubar.

### Bluetooth: AirPods and keyboard ###########################################
#   airpods            connect / disconnect the AirPods
#   keyboard           re-pair the Magic Keyboard with this Mac and connect it
#                      (e.g. after switching laptops): forgets it, then pairs
# Requires: brew install blueutil coreutils, and Bluetooth access for the
# terminal app (System Settings > Privacy & Security > Bluetooth).
# Find device addresses with: blueutil --paired

# Bluetooth devices
AIRPODS_BT_ADDRESS="74-77-86-6d-d5-a9"
AIRPODS_NAME="🍤 shrimps"
KEYBOARD_BT_ADDRESS="38-09-fb-35-90-5d"
KEYBOARD_NAME="⌨️ taste"

# Configuration
BT_STATUS_COLUMN=36
BT_COMMAND_END_COLUMN=24
BT_TIMEOUT=8

# Render Bluetooth status

bt_status() {
  local name="$1"
  local message="$2"
  local color="$3"
  local first="${4:-0}"

  local width=24
  local padding=$((width - ${#name}))
  local dot_color="#858A93"
  local dots="" leading_dots=""
  local i

  (( padding < 3 )) && padding=3

  # Dots between device name and status
  for (( i = 0; i < padding - 2; i++ )); do
    dots+="·"
  done

  if [[ -t 1 ]] && (( COLUMNS >= BT_STATUS_COLUMN + 55 )); then
    (( first )) && printf '\033[1A'

    # Dots between command and device name
    local gap=$((BT_STATUS_COLUMN - BT_COMMAND_END_COLUMN - 2))

    if (( gap > 0 )); then
      for (( i = 0; i < gap; i++ )); do
        leading_dots+="·"
      done

      printf '\r\033[%dG' "$BT_COMMAND_END_COLUMN"
      print -Pn " %F{$dot_color}${leading_dots}%f "
    fi

    # Position device name at fixed column
    printf '\033[%dG\033[0K' "$BT_STATUS_COLUMN"
  else
    printf '\r\033[2K'
  fi

  # Bold device name
  print -Pn "%B${name}%b"

  # Subtle dotted separator
  print -Pn " %F{$dot_color}${dots}%f "

  # Colored status
  print -Pn "%F{$color}${message}%f"
}

# Read connection state with a timeout
bt_get_state() {
  local address="$1"

  gtimeout -k 0.2s 1s \
    blueutil --is-connected "$address" 2>/dev/null
}

# Stop and reap a background Bluetooth operation
bt_stop() {
  local pid="$1"

  kill -KILL "$pid" 2>/dev/null
  wait "$pid" 2>/dev/null

  return 0
}

# Toggle Bluetooth connection
bt_toggle() {
  setopt local_options no_monitor

  local address="$1"
  local name="${2:-Bluetooth device}"
  local state action expected result
  local operation_pid
  local -i missing=0
  local -i verified=0
  local -i saw_valid_state=0
  local -F deadline

  # Check dependencies
  if ! command -v blueutil &>/dev/null; then
    print -P "%F{red}✗ Missing dependency: blueutil%f"
    print -r -- "  brew install blueutil"
    missing=1
  fi

  if ! command -v gtimeout &>/dev/null; then
    print -P "%F{red}✗ Missing dependency: coreutils%f"
    print -r -- "  brew install coreutils"
    missing=1
  fi

  (( missing )) && return 1

  if [[ -z "$address" ]]; then
    print -P "%F{red}✗ No Bluetooth address provided%f"
    return 1
  fi

  if ! zmodload zsh/datetime 2>/dev/null; then
    print -P "%F{red}✗ Cannot load zsh/datetime%f"
    return 1
  fi

  # Determine current state
  if ! state=$(bt_get_state "$address"); then
    bt_status "$name" "? Unknown" 214 1
    print
    return 1
  fi

  case "$state" in
    1)
      action="--disconnect"
      expected=0
      bt_status "$name" "~ Disconnecting" 245 1
      ;;
    0)
      action="--connect"
      expected=1
      bt_status "$name" "~ Connecting" yellow 1
      ;;
    *)
      bt_status "$name" "? Unknown" 214 1
      print
      return 1
      ;;
  esac

  # Start operation asynchronously
  blueutil "$action" "$address" >/dev/null 2>&1 &
  operation_pid=$!

  # Poll until state changes or timeout expires
  deadline=$(( EPOCHREALTIME + BT_TIMEOUT ))

  while (( EPOCHREALTIME < deadline )); do
    if result=$(bt_get_state "$address"); then
      if [[ "$result" == "0" || "$result" == "1" ]]; then
        saw_valid_state=1

        if [[ "$result" == "$expected" ]]; then
          verified=1
          break
        fi
      fi
    fi

    sleep 0.25
  done

  # Clean up the background operation, even if it hung
  bt_stop "$operation_pid"

  # One final verification if polling didn't confirm success
  if (( ! verified )); then
    if result=$(bt_get_state "$address"); then
      if [[ "$result" == "0" || "$result" == "1" ]]; then
        saw_valid_state=1
        [[ "$result" == "$expected" ]] && verified=1
      fi
    fi
  fi

  # Display final status
  if (( verified )); then
    if [[ "$expected" == 1 ]]; then
      bt_status "$name" "✓ Connected" green
    else
      bt_status "$name" "○ Disconnected" 245
    fi
    print
    return 0
  fi

  if (( saw_valid_state )); then
    bt_status "$name" "✗ Timed out" red
  else
    bt_status "$name" "? Unknown" 214
  fi

  print
  return 1
}

# Device shortcuts
airpods() {
  bt_toggle "$AIRPODS_BT_ADDRESS" "$AIRPODS_NAME"
}

keyboard() {
  bt_repair "$KEYBOARD_BT_ADDRESS" "$KEYBOARD_NAME"
}

# Is the device in this Mac's list of paired devices?
bt_is_paired() {
  blueutil --paired 2>/dev/null | grep -qi -- "${1//:/-}"
}

# Forget a device on this Mac, then pair and connect it again. A Magic Keyboard
# can show as connected yet type nothing, and only a fresh pairing fixes that.
# It stays paired to the last Mac that had it, so it only accepts this one while
# it's advertising: right after being switched off for a few seconds and back on. While it runs, the
# command's own line shows progress, with a grey hint below it:
#   keyboard ···· ⌨️ taste ···· ○ Forgotten ······ ~ Pairing (2/10)
#     Switch ⌨️ taste off and on. ...
# When it's done, the line folds to the result and the hint goes away:
#   keyboard ···· ⌨️ taste ···· ✓ Paired & connected
bt_repair() {
  local address="$1" name="${2:-Bluetooth device}"
  local dot_color="#858A93" message color
  local -i try inline=0 paired=0

  command -v blueutil &>/dev/null || { print -P "%F{red}✗ Missing dependency: blueutil%f"; return 1 }
  command -v gtimeout &>/dev/null || { print -P "%F{red}✗ Missing dependency: coreutils%f"; return 1 }
  # One line holds both statuses, so it needs a wide window; otherwise one per line
  [[ -t 1 ]] && (( COLUMNS >= BT_STATUS_COLUMN + 80 )) && inline=1

  # 1. Forget
  local forgotten="○ Forgotten"
  if bt_is_paired "$address"; then
    blueutil --disconnect "$address" &>/dev/null
    blueutil --unpair "$address" &>/dev/null      # blueutil calls this experimental
    sleep 1
    if bt_is_paired "$address"; then
      bt_status "$name" "✗ Still paired" red 1; print
      print -r -- "  Remove it in System Settings > Bluetooth: ⓘ next to it > Forget This Device."
      return 1
    fi
  else
    forgotten="○ Not paired"
  fi

  # 2. Pair and connect, retrying while the keyboard is switched off and on
  local hint="Switch $name off and on. If macOS asks, press Connect (Cancel breaks the pairing). A Mac nearby that still has it can grab it first."
  if (( inline )); then
    print -Pn "%F{245}  ${hint//\%/%%}%f"         # grey, on the line below the command
    bt_status "$name" "$forgotten" 245 1        # back up to the command's line
    print -Pn " %F{$dot_color}······%f "
    print -n $'\e7'                             # remember where the pairing status goes
  else
    bt_status "$name" "$forgotten" 245; print
    print -P "%F{245}  ${hint//\%/%%}%f"
  fi

  for (( try = 1; try <= 10; try++ )); do
    message="~ Pairing ($try/10)"
    if (( inline )); then print -n $'\e8\e[K'; print -Pn "%F{yellow}$message%f"
    else bt_status "$name" "$message" yellow; fi
    # Pairing can also finish through macOS's own "wants to connect" prompt
    # while blueutil waits, so check the device itself each time. It must be
    # paired as well as connected: the link counts as connected before that
    # prompt is accepted, and the keyboard types nothing until it is.
    bt_is_paired "$address" && [[ $(bt_get_state "$address") == 1 ]] && { paired=1; break }
    gtimeout --foreground 15 blueutil --pair "$address" &>/dev/null
    blueutil --connect "$address" &>/dev/null
    sleep 1
    bt_is_paired "$address" && [[ $(bt_get_state "$address") == 1 ]] && { paired=1; break }
    sleep 1
  done

  if (( paired )); then message="✓ Paired & connected" color=green
  else message="✗ Couldn't pair" color=red; fi
  local fallback="Plug in its cable for a few seconds, or pair it in System Settings > Bluetooth."
  if (( inline )); then
    print -n $'\e8'
    bt_status "$name" "$message" $color         # redraw the line with just the result
    print -n $'\n\e[2K'                         # clear the hint line
    (( paired )) || print -P "%F{245}  $fallback%f"
  else
    bt_status "$name" "$message" $color; print
    (( paired )) || print -P "%F{245}  $fallback%f"
  fi
  (( paired ))
}
