#!/bin/bash

# Docker Tag to test

DOCKERTAG=breezy_badger

# Sets the base folder to mount volumes for testing
HOST_BASE=/Users/malkab/Desktop/Docker_PostGIS_Tests

# Time to wait for containers to launch the DB process
WAIT_TIME=10

# Host user and group to test user mapping
USER=malkab
GROUP=staff


# Folder this script is in
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"


# The simplest, for basic debugging

echo
echo test_00: Simple deployment
echo --------------------------
echo

docker run -d --name "test_00" -P \
       geographica/postgis:$DOCKERTAG


# Change UID and GID from postgres user to match that of /data host mounted volume

echo
echo test_01: Get UID and GID from mounted host volume
echo -------------------------------------------------
echo

mkdir -p $HOST_BASE/test_01_data
chown -R $USER:$GROUP $HOST_BASE

docker run -d -P --name "test_01" \
       -v $HOST_BASE/test_01_data:/data \
       geographica/postgis:$DOCKERTAG


# Testing locale generation and user creation

echo
echo test_02: Locale and user generation
echo -----------------------------------
echo

docker run -d -P --name "test_02" \
       -e "LOCALE=ru_RU" \
       -e "CREATE_USER=project" \
       -e "CREATE_USER_PASSWD=project_pass" \
       geographica/postgis:$DOCKERTAG


# Testing encrypted password

echo
echo test_03: Encrypted password
echo ---------------------------
echo

export PGPASSWD="md5"$(printf '%s' "new_password_here" "postgres" | md5sum | cut -d ' ' -f 1) && \
    docker run -d -P --name "test_03" \
	   -e "POSTGRES_PASSWD=${PGPASSWD}" \
	   geographica/postgis:$DOCKERTAG 


# Testing launch of psql scripts

echo
echo test_04: Launch of psql scripts
echo -------------------------------
echo

docker run -d --name "test_04" -P \
       -v $DIR/Assets:/init_scripts \
       -e "LOCALE=es_ES" \
       -e "PSQL_SCRIPTS=/init_scripts/Schema00_DDL.sql;/init_scripts/Schema01_DDL.sql" \
       -e "CREATE_USER=project" \
       -e "CREATE_USER_PASSWD=project_pass" \
       geographica/postgis:$DOCKERTAG


# Testing backup of user database

echo
echo test_05: Backup database
echo ------------------------
echo

groupadd -g 2003 thedockergroup
useradd --shell /bin/bash -M --uid 2002 --gid 2003 thedockeruser

mkdir -p $HOST_BASE/test_05_output
chown -R 2002:2003 $HOST_BASE/test_05_output

docker run -d --name "test_05" -P \
       -v $HOST_BASE/test_05_output:/output \
       -v $DIR/Assets:/init_scripts \
       -e "UID_FOLDER=/output/" \
       -e "LOCALE=es_ES" \
       -e "CREATE_USER=project" \
       -e "CREATE_USER_PASSWD=project_pass" \
       -e "PSQL_SCRIPTS=/init_scripts/Schema00_DDL.sql;/init_scripts/Schema01_DDL.sql" \
       -e "BACKUP_DB=project" \
       geographica/postgis:$DOCKERTAG

echo Waiting for container test_05 to perform initalization...

sleep $WAIT_TIME

docker exec -ti test_05 make_backups


# # Testing backup restoration

# echo
# echo test_06: Backup restoration
# echo ---------------------------
# echo

# docker run -d --name "test_06" -P \
#        -v $DIR/Assets:/Assets \
#        -e "LOCALE=es_ES" \
#        -e "PSQL_SCRIPTS=/Assets/Create_role.sql" \
#        -e "PG_RESTORE=-C -F c -v -U postgres /Assets/project.backup" \
#        geographica/postgis:$DOCKERTAG


# # Testing all variables

# echo
# echo test_07: Test all ENV variables
# echo -------------------------------
# echo

# mkdir -p $HOST_BASE/test_07_output
# mkdir -p $HOST_BASE/test_07_data
# chown -R $USER:$GROUP $HOST_BASE/test_07_output
# chown -R $USER:$GROUP $HOST_BASE/test_07_data

# export PGPASSWD="md5"$(printf '%s' "new_password_here" "postgres" | md5sum | cut -d ' ' -f 1) && \
#     docker run -d --name "test_07" -P \
# 	   -v $DIR/Assets:/init_scripts \
# 	   -v $HOST_BASE/test_07_output:/output_changed \
# 	   -v $HOST_BASE/test_07_data:/data_changed \
# 	   -e "POSTGRES_PASSWD=${PGPASSWD}" \
#            -e "POSTGRES_DATA_FOLDER=/data_changed" \
# 	   -e "POSTGRES_OUTPUT_FOLDER=/output_changed" \
# 	   -e "ENCODING=UTF-8" \
# 	   -e "LOCALE=es_ES" \
# 	   -e "PSQL_SCRIPTS=/init_scripts/Create_role.sql;/init_scripts/Schema00_DDL.sql;/init_scripts/Schema01_DDL.sql;/init_scripts/Schema02_DDL.sql" \
# 	   -e "CREATE_USER=project2;project_pass2" \
# 	   -e "BACKUP_DB=project" \
# 	   -e "PG_RESTORE=-C -F c -v -d postgres -U postgres /init_scripts/project.backup" \
# 	   -e "PG_HBA=local all all trust#host all all 127.0.0.1/32 trust#host all all 0.0.0.0/0 md5#host all all ::1/128 trust#host project project 0.0.0.0/0 trust" \
# 	   -e "PG_CONF=max_connections=10#listen_addresses='*'#shared_buffers=256MB#dynamic_shared_memory_type=posix#log_timezone='UTC'#datestyle='iso, mdy'#timezone='UTC'" \
# 	   geographica/postgis:$DOCKERTAG

	   
# echo Waiting for container test_07 to perform initalization...

# sleep $WAIT_TIME

# docker exec -ti test_07 make_backups


# # Testing datastore persistence and reutilization

# echo
# echo test_08: Datastore persistence and reutilization
# echo ------------------------------------------------
# echo

# mkdir -p $HOST_BASE/test_08_pgdata
# chown -R $USER:$GROUP $HOST_BASE

# docker create --name test_08_pgdata -v $HOST_BASE/test_08_pgdata:/data debian /bin/true

# docker run -d --name test_08_a -P --volumes-from test_08_pgdata geographica/postgis:$DOCKERTAG

# echo Waiting for container test_08_a to initalize

# sleep $WAIT_TIME

# docker stop test_08_a

# docker run -d --name test_08_b -P --volumes-from test_08_pgdata geographica/postgis:$DOCKERTAG


# # Testing psql and pg_dump automatic session 

# echo
# echo test_09: psql and pg_dump automatic session
# echo -------------------------------------------
# echo

# mkdir -p $HOST_BASE/test_09_out
# chown -R $USER:$GROUP $HOST_BASE

# echo
# echo pg_dump
# echo

# # pg_dump

# docker run --rm -v $HOST_BASE/test_09_out:/d --link test_07:pg \
#        geographica/postgis:$DOCKERTAG \
#        PGPASSWORD="new_password_here" pg_dump -b -E UTF8 -f /d/dump_test_07 -F c \
#        -v -Z 9 -h pg -p 5432 -U postgres project

# echo
# echo psql command
# echo

# # psql command

# docker run --rm --link test_07:pg \
#        geographica/postgis:$DOCKERTAG \
#        PGPASSWORD="new_password_here" psql -h pg -p 5432 -U postgres postgres -c "\l"


# # Testing PostGIS

# echo
# echo test_10: PostGIS
# echo ----------------
# echo

# docker run -d --name test_10 -e "CREATE_USER=postgis;postgis" -P geographica/postgis:$DOCKERTAG

# echo
# echo Waiting for container test_10 to initialize

# sleep $WAIT_TIME

# echo
# echo Create PostGIS extension

# docker run --rm --link test_10:pg geographica/postgis:$DOCKERTAG PGPASSWORD="postgres" \
#        psql -h pg -U postgres postgis -c "create extension postgis;"

# echo
# echo Test GeoJSON

# docker run --rm --link test_10:pg geographica/postgis:$DOCKERTAG \
#        PGPASSWORD="postgis" \
#        psql -h pg -U postgis postgis -c "SELECT ST_GeomFromGeoJSON('{\"type\":\"Point\",\"coordinates\":[-48.23456,20.12345]}');"

# echo
# echo Test PROJ4 datum shiftings

# docker run --rm -v $DIR/Assets:/Assets --link test_10:pg geographica/postgis:$DOCKERTAG /Assets/proj4/proj4_test.sh

# echo
# echo Test GDAL datum shiftings

# docker run --rm -v $DIR/Assets:/Assets --link test_10:pg geographica/postgis:$DOCKERTAG /Assets/gdal/gdal-test.sh

# echo
# echo Test PostGIS datum shiftings

# docker run --rm -v $DIR/Assets:/Assets --link test_10:pg geographica/postgis:$DOCKERTAG \
#        PGPASSWORD="postgis" psql -h pg -U postgis postgis -c "\i /Assets/postgis/postgis_test.sql"


# # Testing custom user

# echo
# echo test_11: Custom User
# echo --------------------
# echo

# mkdir -p $HOST_BASE/test_11
# chown -R 2002:2003 $HOST_BASE/test_11

# docker run -d --name "test_11" -P \
#        -v $HOST_BASE/test_11:/src_data \
#        -e "UID_FOLDER=/src_data/" \
#        -e "LOCALE=es_ES" \
#        geographica/postgis:$DOCKERTAG

# sleep $WAIT_TIME

# docker exec test_11 su -s /bin/bash -c "touch /src_data/touch" postgres
