#!/bin/bash

# Sets the base folder to mount volumes for testing
HOST_BASE=/home/malkab/Desktop/Docker_PostGIS_Tests

# Time to wait for containers to launch the DB process
WAIT_TIME=10

# Host user and group to test user mapping
USER=malkab
GROUP=malkab
UUID=1000
UGID=1000


# Folder this script is in
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"


# The simplest, for basic debugging

echo
echo test_00
echo -------
echo

docker run -d --name "test_00" -P \
       geographica/postgis:postgresql-9.5.0-postgis-2.2.1-gdal-2.0.2-patched


# Change UID and GID from postgres user to match that of /data host mounted volume

echo
echo test_01
echo -------
echo

mkdir -p $HOST_BASE/test_01_data
chown -R $USER:$GROUP $HOST_BASE

docker run -d -P --name "test_01" \
       -v $HOST_BASE/test_01_data:/data \
       geographica/postgis:postgresql-9.5.0-postgis-2.2.1-gdal-2.0.2-patched


# Testing locale generation and user creation

echo
echo test_02
echo -------
echo

docker run -d -P --name "test_02" \
       -e "LOCALE=ru_RU" \
       -e "CREATE_USER=project" \
       -e "CREATE_USER_PASSWD=project_pass" \
       geographica/postgis:postgresql-9.5.0-postgis-2.2.1-gdal-2.0.2-patched


# Testing encrypted password

echo
echo test_03
echo -------
echo

export PGPASSWD="md5"$(printf '%s' "new_password_here" "postgres" | md5sum | cut -d ' ' -f 1) && \
    docker run -d -P --name "test_03" \
	   -e "POSTGRES_PASSWD=${PGPASSWD}" \
	   geographica/postgis:postgresql-9.5.0-postgis-2.2.1-gdal-2.0.2-patched 


# Testing launch of psql scripts

echo
echo test_04
echo -------
echo

docker run -d --name "test_04" -P \
       -v $DIR/Assets:/init_scripts \
       -e "LOCALE=es_ES" \
       -e "PSQL_SCRIPTS=/init_scripts/Schema00_DDL.sql;/init_scripts/Schema01_DDL.sql" \
       -e "CREATE_USER=project" \
       -e "CREATE_USER_PASSWD=project_pass" \
       geographica/postgis:postgresql-9.5.0-postgis-2.2.1-gdal-2.0.2-patched


# Testing backup of user database

echo
echo test_05
echo -------
echo

mkdir -p $HOST_BASE/test_05_output
chown -R $USER:$GROUP $HOST_BASE

docker run -d --name "test_05" -P \
       -v $HOST_BASE/test_05_output:/output \
       -v $DIR/Assets:/init_scripts \
       -e "UGID=${UUID};${UGID}" \
       -e "LOCALE=es_ES" \
       -e "CREATE_USER=project" \
       -e "CREATE_USER_PASSWD=project_pass" \
       -e "PSQL_SCRIPTS=/init_scripts/Schema00_DDL.sql;/init_scripts/Schema01_DDL.sql" \
       -e "BACKUP_DB=project" \
       geographica/postgis:postgresql-9.5.0-postgis-2.2.1-gdal-2.0.2-patched

echo Waiting for container test_05 to perform initalization...

sleep $WAIT_TIME

docker exec -ti test_05 make_backups


# Testing backup restoration

echo
echo test_06
echo -------
echo

docker run -d --name "test_06" -P \
       -v $DIR/Assets:/Assets \
       -e "UGID=${UUID};${UGID}" \
       -e "LOCALE=es_ES" \
       -e "PSQL_SCRIPTS=/Assets/Create_role.sql" \
       -e "PG_RESTORE=-C -F c -v -U postgres /Assets/project.backup" \
       geographica/postgis:postgresql-9.5.0-postgis-2.2.1-gdal-2.0.2-patched


# Testing all variables

echo
echo test_07
echo -------
echo

mkdir -p $HOST_BASE/test_07_output
mkdir -p $HOST_BASE/test_07_data
chown -R $USER:$GROUP $HOST_BASE

export PGPASSWD="md5"$(printf '%s' "new_password_here" "postgres" | md5sum | cut -d ' ' -f 1) && \
    docker run -d --name "test_07" -P \
	   -v $DIR/Assets:/init_scripts \
	   -v $HOST_BASE/test_07_output:/output_changed \
	   -v $HOST_BASE/test_07_data:/data_changed \
	   -e "POSTGRES_PASSWD=${PGPASSWD}" \
           -e "POSTGRES_DATA_FOLDER=/data_changed" \
	   -e "POSTGRES_OUTPUT_FOLDER=/output_changed" \
	   -e "ENCODING=UTF-8" \
	   -e "LOCALE=es_ES" \
	   -e "PSQL_SCRIPTS=/init_scripts/Create_role.sql;/init_scripts/Schema00_DDL.sql;/init_scripts/Schema01_DDL.sql;/init_scripts/Schema02_DDL.sql" \
	   -e "CREATE_USER=project2" \
	   -e "CREATE_USER_PASSWD=project_pass2" \
	   -e "BACKUP_DB=project" \
	   -e "PG_RESTORE=-C -F c -v -d postgres -U postgres /init_scripts/project.backup" \
	   -e "UGID=${UUID};${UGID}" \
	   -e "PG_HBA=local all all trust#host all all 127.0.0.1/32 trust#host all all 0.0.0.0/0 md5#host all all ::1/128 trust#host project project 0.0.0.0/0 trust" \
	   -e "PG_CONF=max_connections=10#listen_addresses='*'#shared_buffers=256MB#dynamic_shared_memory_type=posix#log_timezone='UTC'#datestyle='iso, mdy'#timezone='UTC'" \
	   geographica/postgis:postgresql-9.5.0-postgis-2.2.1-gdal-2.0.2-patched

	   
echo Waiting for container test_07 to perform initalization...

sleep $WAIT_TIME

docker exec -ti test_07 make_backups


# Testing datastore persistence and reutilization

echo
echo test_08
echo -------
echo

mkdir -p $HOST_BASE/test_08_pgdata
chown -R $USER:$GROUP $HOST_BASE

docker create --name test_08_pgdata -v $HOST_BASE/test_08_pgdata:/data debian /bin/true

docker run -d --name test_08_a -P --volumes-from test_08_pgdata geographica/postgis:postgresql-9.5.0-postgis-2.2.1-gdal-2.0.2-patched

echo Waiting for container test_08_a to initalize

sleep $WAIT_TIME

docker stop test_08_a

docker run -d --name test_08_b -P --volumes-from test_08_pgdata geographica/postgis:postgresql-9.5.0-postgis-2.2.1-gdal-2.0.2-patched
