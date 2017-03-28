#!/bin/bash

set -e

log(){
    echo "$(date +"%Y-%m-%d %T") > $1" >> /log.txt
}

# Generate locale
LANG=${LOCALE}.${ENCODING}

locale-gen ${LANG} > /dev/null

log "Locale ${LOCALE}.${ENCODING} generated"

# Create user postgres if does not exists

/usr/local/bin/create_postgres_user.sh

# Check if command is just "run_default"

if [ "$1" = 'run_default' ]; then
  log "Running server"

  # Check if data folder is empty. If it is, configure the dataserver
  if [ -z "$(ls -A "$POSTGRES_DATA_FOLDER")" ]; then
    log "Initilizing datastore..."

    # Modify data store
    chown postgres:postgres ${POSTGRES_DATA_FOLDER}
    chmod 700 ${POSTGRES_DATA_FOLDER}

    # Modify output folder
    chown postgres:postgres ${POSTGRES_OUTPUT_FOLDER}
    chmod 700 ${POSTGRES_OUTPUT_FOLDER}

    log "postgres user created..."

    # Create datastore
    su postgres -c "initdb --encoding=${ENCODING} --locale=${LANG} --lc-collate=${LANG} --lc-monetary=${LANG} --lc-numeric=${LANG} --lc-time=${LANG} -D ${POSTGRES_DATA_FOLDER}"

    log "Datastore created..."

    # Create log folder
    mkdir -p ${POSTGRES_DATA_FOLDER}/logs
    chown postgres:postgres ${POSTGRES_DATA_FOLDER}/logs

    log "Log folder created..."

    # Erase default configuration and initialize it
    su postgres -c "rm ${POSTGRES_DATA_FOLDER}/pg_hba.conf"
    su postgres -c "pg_hba_conf a \"${PG_HBA}\""

    # Modify basic configuration
    su postgres -c "rm ${POSTGRES_DATA_FOLDER}/postgresql.conf"
    PG_CONF="${PG_CONF}#lc_messages='${LANG}'#lc_monetary='${LANG}'#lc_numeric='${LANG}'#lc_time='${LANG}'"
    su postgres -c "postgresql_conf a \"${PG_CONF}\""

    # Establish postgres user password and run the database
    su postgres -c "pg_ctl -w -D ${POSTGRES_DATA_FOLDER} start"
    su postgres -c "psql -h localhost -U postgres -p 5432 -c \"alter role postgres password '${POSTGRES_PASSWD}';\""

    log "Configurating and adding postgres user to the database..."

    # Check if CREATE_USER is not null
    if ! [ "$CREATE_USER" = "null;null" ]; then
      log "-----------------------------------------"
      log "Creating database and user ${CREATE_USER}"
      log "-----------------------------------------"

      set -- "$CREATE_USER"
      IFS=";"; declare -a Array=($*)
      USERNAME="${Array[0]}"
      USERPASS="${Array[1]}"

      su postgres -c "psql -h localhost -U postgres -p 5432 -c \"create user ${USERNAME} with login password '${USERPASS}';\""
      su postgres -c "psql -h localhost -U postgres -p 5432 -c \"create database ${USERNAME} with owner ${USERNAME};\""
    fi

    log "Running custom scripts..."

    # Run scripts
    python /usr/local/bin/run_psql_scripts

    log "Restoring database..."

    # Restore backups
    python /usr/local/bin/run_pg_restore

    log "Stopping the server..."

    # Stop the server
    su postgres -c "pg_ctl -w -D ${POSTGRES_DATA_FOLDER} stop"
  else
    log "Datastore already exists..."
  fi

  log "Starting the server..."

  # Start the database
  exec gosu postgres postgres -D $POSTGRES_DATA_FOLDER
else
  exec env "$@"
fi
