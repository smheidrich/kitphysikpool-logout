#!/bin/bash
USER="$(whoami)"
HOST_TEMPLATE='fphct%02d'
START_HOST_NUMBER=1
END_HOST_NUMBER=30

i="$START_HOST_NUMBER"
while (( i <= END_HOST_NUMBER )); do
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
