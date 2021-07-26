#!/usr/bin/env bash

# Handle inputs
##Defaults
TARGET_HOST="iridis5_b.soton.ac.uk"
LOCAL_HOST=$(hostname)
IDENTITY=~/.ssh/transfer_key


# Clean up when finished
cleanup (){
rm ${IDENTITY} 
rm ${IDENTITY}.pub
}

# Generate key
echo "Generate key"
ssh-keygen -t ecdsa -f ${IDENTITY} -q -N ""

# Copy key to new server
echo "Copy key"
ssh-copy-id -i ${IDENTITY} ${TARGET_HOST}

# Copy data from file lists
echo "Copy Data"
ssh -i ${IDENTITY} ${TARGET_HOST} "uptime"

# Trigger clean up
#cleanup
