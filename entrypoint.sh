#!/bin/sh
set -e

echo "Setting up SSH directory"
SSH_PATH="$HOME/.ssh"
mkdir -p "$SSH_PATH"
chmod 700 "$SSH_PATH"

echo "Saving SSH key"
echo "$PRIVATE_KEY" > "$SSH_PATH/deploy_key"
chmod 600 "$SSH_PATH/deploy_key"

if [ -n "$FORCE_DEPLOY" ]; then
    echo "Enabling force deploy"
    FORCE_DEPLOY="--force"
fi

GIT_SSH_COMMAND="ssh -p ${PORT-22} -i $SSH_PATH/deploy_key"

if [ -n "$HOST_KEY" ]; then
    echo "Adding hosts key to known_hosts"
    echo "$HOST_KEY" >> "$SSH_PATH/known_hosts"
    chmod 600 "$SSH_PATH/known_hosts"
else
    echo "Disabling host key checking"
    GIT_SSH_COMMAND="$GIT_SSH_COMMAND -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no"
fi

echo "The deploy is starting"

GIT_SSH_COMMAND="$GIT_SSH_COMMAND" git push "dokku@$HOST:$PROJECT" HEAD:master "$FORCE_DEPLOY"
