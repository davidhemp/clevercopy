#!/usr/bin/env bash

# Handle inputs
##Defaults
TARGET_HOST="iridis5_b.soton.ac.uk"
LOCAL_HOST=$(hostname)
IDENTITY=~/.ssh/transfer_key

TARGET_PATH="/scratch/$(id -un)/copied_data/"


# Clean up when finished
cleanup (){
    rm ${IDENTITY} 
    rm ${IDENTITY}.pub
    kill ${SSH_AGENT_PID}
}

trap cleanup EXIT

#Passcode, not partically secure but should be fine when used with a key
PASSCODE="$(expr $RANDOM \* $RANDOM)"

# Generate key
ssh-keygen -t ecdsa -f ${IDENTITY} -q -N "${PASSCODE}"
echo "When asked, the passcode for this session is: ${PASSCODE}"

# Start agent and add key
# agent_run_state: 0=agent running w/ key; 1=agent w/o key; 2= agent not running
agent_run_state=$(ssh-add -l >| /dev/null 2>&1; echo $?)

LIFETIME=86400
if [ ! "$SSH_AUTH_SOCK" ] || [ $agent_run_state = 2 ]; then
    eval `timeout 24h ssh-agent`
    ssh-add -t ${LIFETIME} ${IDENTITY} 
elif [ "$SSH_AUTH_SOCK" ] && [ $agent_run_state = 1 ]; then
    ssh-add -t ${LIFETIME} ${IDENTITY}
fi

# Copy key to new server
ssh-copy-id -i ${IDENTITY} ${TARGET_HOST} > /dev/null

# Copy data from file lists
echo "Copy Data"

ssh -i ${IDENTITY} ${TARGET_HOST} "w"
ssh -i ${IDENTITY} ${TARGET_HOST} "uptime"

