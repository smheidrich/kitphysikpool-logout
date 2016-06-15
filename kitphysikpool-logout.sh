#!/bin/bash
USER="$(whoami)"
HOST_TEMPLATE='fphct%02d'
NUM_HOSTS=30
i=1

while (( i < 30 )); do
  echo "pruefe: $host"
  host="$(printf "$HOST_TEMPLATE" "$i")"
  echo -n users \
  | ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null \
  "$USER"@"$host" 2>/dev/null \
  | grep "$USER" >&/dev/null \
  && [ "$host" != "$(hostname)" ] \
  && printf '\x1B[A' && echo -n "eingeloggt auf: $host" \
  && echo "killall startkde" \
  | ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null \
  "$USER"@"$host" 2>/dev/null \
  && echo " - beendet" \
  || printf '\x1B[A'
  ((i++))
done
