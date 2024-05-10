#!/bin/sh

set -e
CONFIG_PATH=/etc/nutcracker.conf

generate_config() {
    if [ "$REDIS_AUTH" ];then
        REDIS_AUTH="redis_auth: ${REDIS_AUTH}"
    fi
    cat > $CONFIG_PATH <<EOF
pool:
  listen: 0.0.0.0:${LISTEN_PORT}
  hash: ${HASH}
  distribution: ${DISTRIBUTION}
  redis: true
  ${REDIS_AUTH}
  auto_eject_hosts: ${AUTO_EJECT_HOSTS}
  timeout: ${TIMEOUT}
  server_retry_timeout: ${SERVER_RETRY_TIMEOUT}
  server_failure_limit: ${SERVER_FAILURE_LIMIT}
  server_connections: ${SERVER_CONNECTIONS}
  preconnect: ${PRECONNECT}
  servers:
EOF

    IFS=,
    for server in $REDIS_SERVERS; do
      echo "   - ${server}" >> $CONFIG_PATH
    done
}


if [ ! -e "$CONFIG_PATH" ]; then
    generate_config
fi

cat /etc/nutcracker.conf|awk '{printf("%03s: %s\n",NR,$0);}'
exec "$@"
