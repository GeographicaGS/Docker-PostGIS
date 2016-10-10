#!/bin/bash

set -e

log(){
    echo "$(date +"%Y-%m-%d %T") > $1" >> /log.txt
}


if ! id postgres > /dev/null 2>&1; then
    log "Creating postgres user"
    
    UID_DATA="$(folder_uid ${POSTGRES_DATA_FOLDER})"
    GID_DATA="$(folder_gid ${POSTGRES_DATA_FOLDER})"

    UID_OUT="$(folder_uid ${POSTGRES_OUTPUT_FOLDER})"
    GID_OUT="$(folder_gid ${POSTGRES_OUTPUT_FOLDER})"    

    if [ ! $UID_FOLDER = "null" ]; then
	UUID="$(folder_uid ${UID_FOLDER})"
	UGID="$(folder_gid ${UID_FOLDER})"
    fi

    log "Data folder UID: ${UID_DATA}, GID: ${GID_DATA}"
    log "Output folder UID: ${UID_OUT}, GID: ${GID_OUT}"
    log "User folder UID: ${UUID}, GID: ${UGID}"

    # User and group ID precedence
    if [ ! $UUID = "null" ] && [ ! $UGID = "null" ]; then
	FUID=$UUID
	FGID=$UGID

	log "Identified custom user ID: ${FUID}, ${FGID}"
    elif [ ! $UID_OUT = 0 ] && [ ! $GID_OUT = 0 ]; then
	FUID=$UID_OUT
	FGID=$GID_OUT

	log "Identified output folder user ID: ${FUID}, ${FGID}"
    elif [ ! $UID_DATA = 0 ] && [ ! $GID_DATA = 0 ]; then
	FUID=$UID_DATA
	FGID=$GID_DATA

	log "Identified data folder user ID: ${FUID}, ${FGID}"
    else
	FUID=-1
	FGID=-1

	log "User ID to be determined by system"
    fi

    if [ $FUID = -1 ] && [ $FGID = -1 ]; then
	groupadd postgres
	useradd -r --home $POSTGRES_DATA_FOLDER -g postgres postgres
    else
	groupadd -g $FGID postgres
	useradd -r --home $POSTGRES_DATA_FOLDER --uid $FUID --gid $FGID postgres	
    fi

    chown postgres:postgres ${POSTGRES_DATA_FOLDER}
    chmod 700 ${POSTGRES_DATA_FOLDER}
    
    echo "postgres:${POSTGRES_PASSWD}" | chpasswd -e
fi    
