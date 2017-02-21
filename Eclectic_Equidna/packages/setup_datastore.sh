#!/bin/bash

set -e

log(){
    echo "$(date +"%Y-%m-%d %T") > $1" >> /log.txt
}

# Generate locale
LANG=${LOCALE}.${ENCODING}

locale-gen ${LANG} > /dev/null

log "Locale ${LOCALE}.${ENCODING} generated"

log "Running server"

# Check if data folder is empty. If it is, configure the dataserver
log "Initializing datastore..."

# Create datastore
su postgres -c "initdb --encoding=${ENCODING} --locale=${LANG} --lc-collate=${LANG} --lc-monetary=${LANG} --lc-numeric=${LANG} --lc-time=${LANG} -D /data/"

log "Datastore created..."

# Create log folder
mkdir -p /data/logs
chown postgres:postgres /data/logs

log "Log folder created..."

# Erase default configuration and initialize it
su postgres -c "rm /data/pg_hba.conf"
su postgres -c "pg_hba_conf a \"${PG_HBA}\""

# Modify basic configuration
su postgres -c "rm /data/postgresql.conf"
PG_CONF="${PG_CONF}#lc_messages='${LANG}'#lc_monetary='${LANG}'#lc_numeric='${LANG}'#lc_time='${LANG}'"
su postgres -c "postgresql_conf a \"${PG_CONF}\""

# Establish postgres user password and run the database
su postgres -c "pg_ctl -w -D /data/ start"
su postgres -c "psql -h localhost -U postgres -p 5432 -c \"alter role postgres password '${POSTGRES_PASSWD}';\""

log "Configurating and adding postgres user to the database..."

log "Stopping the server..."

# Stop the server
su postgres -c "pg_ctl -w -D /data/ stop"
