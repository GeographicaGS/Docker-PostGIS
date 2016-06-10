#!/bin/bash

# Sets the base folder to mount volumes for testing
HOST_BASE=/home/malkab/Desktop/Docker_PostGIS_Tests

# Host user and group to test user mapping
USER=malkab
GROUP=malkab
UUID=1000
UGID=1000


# Folder this script is in
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"


# The simplest, for basic debugging

docker run -d --name "test_00" -P geographica/postgis:postgresql-9.5.0-postgis-2.2.1-gdal-2.0.2-patched


# Change UID and GID from postgres user to match that of /data host mounted volume

mkdir -p $HOST_BASE/test_01_data
chown -R $USER:$GROUP $HOST_BASE

docker run -d --name "test_01" -v $HOST_BASE/test_01_data:/data -P geographica/postgis:postgresql-9.5.0-postgis-2.2.1-gdal-2.0.2-patched


# Testing locale generation and user creation

docker run -d -P --name "test_02" -e "LOCALE=ru_RU" -e "CREATE_USER=project" -e "CREATE_USER_PASSWD=project_pass" geographica/postgis:postgresql-9.5.0-postgis-2.2.1-gdal-2.0.2-patched


# Testing encrypted password

export PGPASSWD="md5"$(printf '%s' "new_password_here" "postgres" | md5sum | cut -d ' ' -f 1) && docker run -d -P --name "test_03" -e "POSTGRES_PASSWD=${PGPASSWD}" -P geographica/postgis:postgresql-9.5.0-postgis-2.2.1-gdal-2.0.2-patched 


# Testing launch of psql scripts

docker run -d --name "test_04" -P -v $DIR/SQL_Scripts:/init_scripts -e "LOCALE=es_ES" -e "PSQL_SCRIPTS=/init_scripts/Schema00_DDL.sql;/init_scripts/Schema01_DDL.sql" -e "CREATE_USER=project" -e "CREATE_USER_PASSWD=project_pass" geographica/postgis:postgresql-9.5.0-postgis-2.2.1-gdal-2.0.2-patched


# Testing backup of user database

mkdir -p $HOST_BASE/test_05_output
chown $USER:$GROUP $HOST_BASE

docker run -d --name "test_05" -P -v $HOST_BASE/test_05_output:/output -v $DIR/SQL_Scripts:/init_scripts -e "UID=${UUID}" -e "GID=${UGID}" -e "LOCALE=es_ES" -e "CREATE_USER=project" -e "CREATE_USER_PASSWD=project_pass" -e "PSQL_SCRIPTS=/init_scripts/Schema00_DDL.sql;/init_scripts/Schema01_DDL.sql" -e "BACKUP_DB=project" geographica/postgis:postgresql-9.5.0-postgis-2.2.1-gdal-2.0.2-patched

echo Waiting for container test_05 to perform initalization...

sleep 30

docker exec -ti test_05 make_backups


# Testing backup restoration

docker run -d --name "test_06" -P -v $HOST_BASE/test_05_output:/output -e "UID=${UUID}" -e "GID=${UGID}" -e "LOCALE=es_ES" -v $DIR/SQL_Scripts:/init_scripts -e "PSQL_SCRIPTS=/init_scripts/Create_role.sql" -e "PG_RESTORE=-C -F c -v -U postgres /output/project.backup" geographica/postgis:postgresql-9.5.0-postgis-2.2.1-gdal-2.0.2-patched
