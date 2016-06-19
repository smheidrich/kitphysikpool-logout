#!/bin/bash
# Script for testing kitphysikpool-logout, with and without pre-existing key.
# Needs to be run from inside the pool network (I have a deploy+test script for
# this, but it's specific to my machine so I won't put it in the repository).
export NO_FANCY="yes"
export GO_SLOW="yes"
echo "--------------------------"
echo "Testing with keys present."
echo "--------------------------"
coproc loggedin1 { ssh -tt fphct20; }
./kitphysikpool-logout.sh
wait $loggedin1_PID
sleep 2

echo "-----------------------------"
echo "Testing without keys present."
echo "-----------------------------"
coproc loggedin2 { ssh -tt fphct20; }
sleep 2
echo "Moving authorized_keys to ~/"
mv ~/.ssh/authorized_keys ~/
echo "Running script:"
./kitphysikpool-logout.sh
echo "Moving authorized_keys back to ~/.ssh/"
mv ~/authorized_keys ~/.ssh/
wait $loggedin2_PID

echo "----------------------------------"
echo "All tests successful (apparently)."
echo "----------------------------------"
