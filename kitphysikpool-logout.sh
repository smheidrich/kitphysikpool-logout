#!/bin/bash
USER="$(whoami)"
HOST_TEMPLATE='fphct%02d'
START_HOST_NUMBER=1
END_HOST_NUMBER=30

# Usage: lenient_ssh [-w WARN] user@host
# Establishes SSH connection without asking the user to verify the host's
# identity. Host identity is NOT permanently saved to knows_hosts.
# WARN decides where to put warnings (0: /dev/null, 1: stdout, 2: stderr)
function lenient_ssh () {
  # Argument processing
  OPTIND=0
  warn=2
  getopts "w:" opt || return 1
  if [ "$opt" = "w" ]; then
    warn="$OPTARG"
  fi
  shift $((OPTIND-1))
  dest="$1"
  if [ -z "$dest" ]; then
    echo "lenient_ssh: invalid arguments" 1>&2
    return 1
  fi
  OPTIND=0
  # Actual code
  SSH_CMD="ssh -q -o StrictHostKeyChecking=no \
  -o UserKnownHostsFile=/dev/null $dest"
  if [ "$warn" = 0 ]; then
    $SSH_CMD 2>/dev/null
  elif [ "$warn" = 1 ]; then
    $SSH_CMD 2>&1
  else
    $SSH_CMD
  fi
}

# Moves up one line via ANSI control code, unless NO_FANCY is set.
function line_up () {
  if [ -z "$NO_FANCY" ]; then
    printf '\x1B[A'
  fi
}

i="$START_HOST_NUMBER"
for (( i=START_HOST_NUMBER; i <= END_HOST_NUMBER; i++ )); do
  # Build hostname from template and current number
  host="$(printf "$HOST_TEMPLATE" "$i")"
  # Skip this host if it's the local machine
  [ "$host" = "$(hostname)" ] && continue
  # Output status
  echo "pruefe: $host"
  # SSH to host and get list of logged-in users
  remote_users="$(echo users | lenient_ssh -w 0 "$USER"@"$host")"
  # Check if our user is among them (grep exit status will indicate this, we
  # don't need its output so it is discarded)
  echo "$remote_users" | grep -E '(^| )'"$USER"'( |$)' >&/dev/null
  if [ $? = 0 ]; then
    line_up
    echo -n "eingeloggt auf: $host"
    # "Log out" by killing KDE and save any warnings for later
    msg="$(echo "killall startkde" | lenient_ssh -w 1 "$USER"@"$host")"
    # Check if the logout was successful and print saved warnings otherwise
    if [ $? = 0 ]; then
      echo " - beendet."
    else
      echo " - Fehler beim Beenden. Details:"
      echo "$msg"
    fi
  else
    line_up
  fi
done
