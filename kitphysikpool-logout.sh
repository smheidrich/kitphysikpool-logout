#!/bin/bash
USER="$(whoami)"
HOST_TEMPLATE='fphct%02d'
START_HOST_NUMBER=1
END_HOST_NUMBER=30

AUTHORIZED_KEYS_FILE="$HOME/.ssh/authorized_keys"
SSH_KEY_FILE=""
KEY_IS_TEMP=""

#
# Auxilliary functions etc.
#

# This script will be executed on remote hosts to perform the actual "logout".
# It works by killing all processes except for the bash it is running in ($$)
# and its parent sshd (parent of $$).
# Note that this is a bash script and will fail if the remote shell is sh.
LOGOUT_SCRIPT=$(cat <<'HEREDOC'
parent_pid="$(ps -p $$ -o ppid=)"
kill_pids="$(ps -u "$(id -u)" -o "pid=" | sed -e "/$$/d" -e "/$parent_pid/d")"
kill $kill_pids
HEREDOC
)

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
  # Build SSH command string
  SSH_CMD="ssh -q -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null \
  -o PasswordAuthentication=no -o BatchMode=yes"
  if [ -n "$SSH_KEY_FILE" ]; then
    SSH_CMD="$SSH_CMD -i $SSH_KEY_FILE"
  fi
  SSH_CMD="$SSH_CMD $dest"
  # Execute it with appropriate redirections
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

# Cleanup temporary keys and authorized_keys file
function cleanup_tempkey () {
  if [ -n "$KEY_IS_TEMP" ]; then
    echo "Cleaning up."
    rm "$SSH_KEY_FILE"
    rm "$SSH_KEY_FILE".pub
    rm "$AUTHORIZED_KEYS_FILE"
  fi
}

#
# SSH key setup (if required)
#

# Hostname used to test if SSH can establish a connection
test_host="$(printf "$HOST_TEMPLATE" "$START_HOST_NUMBER")"

# Idea here: If authorized_keys file present, then the user has already set up
# SSH keys and needs to load (ssh-agent) of configure (ssh_config) them.
# Otherwise we generate a temporary keypair for them and put the public key
# into authorized_keys.
if [ -e "$AUTHORIZED_KEYS_FILE" ]; then
  echo "Found authorized_keys file. Not generating temporary SSH key."
  echo -n "Testing connection... "
  msg="$(echo | lenient_ssh -w 1 "$USER"@"$test_host")"
  if [ $? != 0 ]; then
    echo 1>&2 "failed."
    echo 1>&2 "Could not connect to $test_host via SSH. Details:"
    echo 1>&2 "$msg"
    echo 1>&2 "Make sure your authorized SSH keys are loaded into ssh-agent \
or configured via ssh_config."
    exit 1
  else
    echo "OK."
  fi
else
  echo "No authorized_keys file found. Generating temporary SSH key for you."
  mkdir -p ~/.ssh
  SSH_KEY_FILE="$(mktemp -u -p ~/.ssh/)"
  ssh-keygen -b 2048 -t rsa -f "$SSH_KEY_FILE" -q -N ""
  if [ $? != 0 ]; then
    echo 1>&2 "Error while generating SSH key."
    rm "$SSH_TEMP_KEY"
    rm "$SSH_TEMP_KEY".pub
    exit 1
  fi
  # From here on out we want automatic cleanup of the temporary generated key
  # and the authorized_keys file on exit
  KEY_IS_TEMP="yes"
  trap cleanup_tempkey EXIT
  cp "$SSH_KEY_FILE".pub "$AUTHORIZED_KEYS_FILE"
  if [ $? != 0 ]; then
    echo 1>&2 "Error while generating authorized_keys file."
    exit 1
  fi
  echo -n "Testing connection..."
  msg="$(echo | lenient_ssh -w 1 "$USER"@"$test_host")"
  if [ $? != 0 ]; then
    echo 1>&2 "failed."
    echo 1>&2 "Could not connect to $test_host via SSH. Details: "
    echo 1>&2 "$msg"
    exit 1
  else
    echo "OK."
  fi
fi

#
# Actual logout script
#

i="$START_HOST_NUMBER"
for (( i=START_HOST_NUMBER; i <= END_HOST_NUMBER; i++ )); do
  # Build hostname from template and current number
  host="$(printf "$HOST_TEMPLATE" "$i")"
  # Skip this host if it's the local machine
  [ "$host" = "$(hostname)" ] && continue
  # Output status
  echo "Checking: $host"
  # SSH to host and get list of logged-in users
  remote_users="$(echo users | lenient_ssh -w 0 "$USER"@"$host")"
  # Check if our user is among them (grep exit status will indicate this, we
  # don't need its output so it is discarded)
  echo "$remote_users" | grep -E '(^| )'"$USER"'( |$)' >&/dev/null
  if [ $? = 0 ]; then
    line_up
    echo -n "Logged in: $host"
    # "Log out" by executing the contents of LOGOUT_SCRIPT on the remote host
    msg="$(echo "$LOGOUT_SCRIPT" | lenient_ssh -w 1 "$USER"@"$host")"
    # Check if the logout was successful and print saved warnings otherwise
    if [ $? = 0 ]; then
      echo " - logged out."
    else
      echo 1>&2 " - error while logging out. Details:"
      echo 1>&2 "$msg"
    fi
  else
    line_up
  fi
done
echo
