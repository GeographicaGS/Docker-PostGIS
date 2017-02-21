#!/bin/bash

set -e

log(){
    echo "$(date +"%Y-%m-%d %T") > $1" >> /log.txt
}

# Generate locale
LANG=${LOCALE}.${ENCODING}

locale-gen ${LANG} > /dev/null

log "Locale ${LOCALE}.${ENCODING} generated"



# Check if command is just "run_default"

if [ "$1" = 'run_default' ]; then
  if [ -z "$(ls -A "/data/")" ]; then
    /usr/local/bin/setup_datastore.sh
  else
    log "Datastore already exists..."
  fi

  log "Starting the server..."

  # Start the database
  exec gosu postgres postgres -D /data/
else
  exec env "$@"
fi
