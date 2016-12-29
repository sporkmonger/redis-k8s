#!/bin/bash

set -e

# Port on which redis listens for connections.
PORT=6379
CLUSTER_IPS=""

if [[ $(hostname | cut -d'-' -s -f2) == 5 ]]; then
  echo "creating cluster..."
  # Convert all peers to raw addresses
  while read -ra LINE; do
    CLUSTER_IPS="${CLUSTER_IPS} $(getent hosts ${LINE} | cut -d' ' -f1):${PORT}"
  done

  # Wait until local redis is available before proceeding
  until redis-cli -h 127.0.0.1 ping; do sleep 1; done

  # redis-trib.rb should only run once, and should only call yes_or_die once
  # during init. Not wild about possible unintended confirmations...
  echo yes | /usr/local/bin/redis-trib.rb create --replicas 1 ${CLUSTER_IPS}
elif [[ $(hostname | cut -d'-' -s -f2) -gt 5 ]]; then
  echo "meeting cluster..."
  getent hosts redis-0.redis.default.svc.cluster.local
  /usr/local/bin/redis-trib.rb add-node --slave $(getent hosts $(hostname) | cut -d' ' -f1):${PORT} $(getent hosts redis-0.redis.default.svc.cluster.local | cut -d' ' -f1):${PORT}
else
  echo "cluster too small"
fi
