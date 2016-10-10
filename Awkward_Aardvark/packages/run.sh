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
    
    # Check if user postgres exists

    log "Running server"

    # if ! id postgres > /dev/null 2>&1; then
    # 	echo Creating postgres user
	
    # 	UID_DATA="$(folder_uid ${POSTGRES_DATA_FOLDER})"
    # 	GID_DATA="$(folder_gid ${POSTGRES_DATA_FOLDER})"

    # 	UID_OUT="$(folder_uid ${POSTGRES_OUTPUT_FOLDER})"
    # 	GID_OUT="$(folder_gid ${POSTGRES_OUTPUT_FOLDER})"    

    # 	if [ ! $UID_FOLDER = "null" ]; then
    # 	    UUID="$(folder_uid ${UID_FOLDER})"
    # 	    UGID="$(folder_gid ${UID_FOLDER})"
    # 	fi

    # 	echo Data folder UID: $UID_DATA, GID: $GID_DATA
    # 	echo Output folder UID: $UID_OUT, GID: $GID_OUT
    # 	echo User folder UID: $UUID, GID: $UGID

    # 	# User and group ID precedence
    # 	if [ ! $UUID = "null" ] && [ ! $UGID = "null" ]; then
    # 	    FUID=$UUID
    # 	    FGID=$UGID

    # 	    echo Identified custom user ID: $FUID, $FGID
    # 	elif [ ! $UID_OUT = 0 ] && [ ! $GID_OUT = 0 ]; then
    # 	    FUID=$UID_OUT
    # 	    FGID=$GID_OUT

    # 	    echo Identified output folder user ID: $FUID, $FGID
    # 	elif [ ! $UID_DATA = 0 ] && [ ! $GID_DATA = 0 ]; then
    # 	    FUID=$UID_DATA
    # 	    FGID=$GID_DATA

    # 	    echo Identified data folder user ID: $FUID, $FGID
    # 	else
    # 	    FUID=-1
    # 	    FGID=-1

    # 	    echo User ID to be determined by system
    # 	fi

    # 	if [ $FUID = -1 ] && [ $FGID = -1 ]; then
    # 	    groupadd postgres
    # 	    useradd -r --home $POSTGRES_DATA_FOLDER -g postgres postgres
    # 	else
    # 	    groupadd -g $FGID postgres
    # 	    useradd -r --home $POSTGRES_DATA_FOLDER --uid $FUID --gid $FGID postgres	
    # 	fi

    # 	echo "postgres:${POSTGRES_PASSWD}" | chpasswd -e
    # fi    

    
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
