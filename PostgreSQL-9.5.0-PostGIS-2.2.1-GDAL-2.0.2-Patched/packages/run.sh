#!/bin/bash

# Generate locale
LANG=${LOCALE}.${ENCODING}

locale-gen ${LANG}


# Check if data folder is empty. If it is, start the dataserver
if ! [ -f "${POSTGRES_DATA_FOLDER}/postgresql.conf" ]; then
    # Change UID and GID for postgres
    usermod -u 
    
    echo "postgres:${POSTGRES_PASSWD}" | chpasswd -e    
    
    # Modify data store
    mkdir -p ${POSTGRES_DATA_FOLDER}    
    chown postgres:postgres ${POSTGRES_DATA_FOLDER}
    chmod 700 ${POSTGRES_DATA_FOLDER}

    # Create backups folder
    mkdir -p ${POSTGRES_BACKUPS_FOLDER}
    chown postgres:postgres ${POSTGRES_BACKUPS_FOLDER}
    chmod 700 ${POSTGRES_BACKUPS_FOLDER}
    
    # Create datastore
    su postgres -c "initdb --encoding=${ENCODING} --locale=${LANG} --lc-collate=${LANG} --lc-monetary=${LANG} --lc-numeric=${LANG} --lc-time=${LANG} -D ${POSTGRES_DATA_FOLDER}"

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

    # Check if CREATE_USER is not null
    if ! [ "$CREATE_USER" = "null" ]; then
	su postgres -c "psql -h localhost -U postgres -p 5432 -c \"create user ${CREATE_USER} with login password '${CREATE_USER_PASSWD}';\""
	su postgres -c "psql -h localhost -U postgres -p 5432 -c \"create database ${CREATE_USER} with owner ${CREATE_USER};\""
    fi

    # Run scripts
    python /usr/local/bin/run_psql_scripts

    # Restore backups
    python /usr/local/bin/run_pg_restore
    
    # Stop the server
    su postgres -c "pg_ctl -w -D ${POSTGRES_DATA_FOLDER} stop"
fi


# Start the database
exec gosu postgres postgres -D $POSTGRES_DATA_FOLDER
