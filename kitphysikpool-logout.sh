#!/bin/bash
USER="$(whoami)"
HOST_TEMPLATE='fphct%02d'
NUM_HOSTS=30
i=1

while (( i < 30 )); do
  host="$(printf "$HOST_TEMPLATE" "$i")"
  echo -n users \
  | ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null \
  "$USER"@"$host" 2>/dev/null \
  | grep "$USER" >&/dev/null \
  && [ "$host" != "$(hostname)" ] \
  && echo -n "eingeloggt auf: $host" \
  && echo "killall startkde" \
  | ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null \
  "$USER"@"$host" 2>/dev/null \
  && echo " - beendet"
  ((i++))
done
