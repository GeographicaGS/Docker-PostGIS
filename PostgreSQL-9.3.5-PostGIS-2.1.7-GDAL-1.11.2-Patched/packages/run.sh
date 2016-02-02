#!/bin/bash

# Create data store
mkdir -p ${POSTGRES_DATA_FOLDER}
chown postgres:postgres ${POSTGRES_DATA_FOLDER}
chmod 700 ${POSTGRES_DATA_FOLDER}

# Check if data folder is empty. If it is, start the dataserver
if ! [ "$(ls -A ${POSTGRES_DATA_FOLDER})" ]; then
    su postgres -c "initdb --encoding=${ENCODING} --locale=${LOCALE} --lc-collate=${COLLATE} --lc-monetary=${LC_MONETARY} --lc-numeric=${LC_NUMERIC} --lc-time=${LC_TIME} -D ${POSTGRES_DATA_FOLDER}"
    
    # Modify basic configuration
    su postgres -c "echo \"host all all 0.0.0.0/0 md5\" >> $POSTGRES_DATA_FOLDER/pg_hba.conf"
    su postgres -c "echo \"listen_addresses='*'\" >> $POSTGRES_DATA_FOLDER/postgresql.conf"

    # Establish postgres user password and run the database
    su postgres -c "pg_ctl -w -D ${POSTGRES_DATA_FOLDER} start" ; su postgres -c "psql -h localhost -U postgres -p 5432 -c \"alter role postgres password '${POSTGRES_PASSWD}';\"" ; python /usr/local/bin/run_psql_scripts ; su postgres -c "pg_ctl -w -D ${POSTGRES_DATA_FOLDER} stop"
fi

# Start the database
exec gosu postgres postgres -D $POSTGRES_DATA_FOLDER
