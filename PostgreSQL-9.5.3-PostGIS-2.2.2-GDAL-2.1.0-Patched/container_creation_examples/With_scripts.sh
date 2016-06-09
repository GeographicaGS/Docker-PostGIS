#!/bin/bash

docker run -ti --rm -P -v /home/git/Docker-Postgis/PostgreSQL-9.5.0-PostGIS-2.2.1-GDAL-2.0.2-Patched/container_creation_examples/SQL_Scripts:/init_scripts -e "LOCALE=es_ES" -e "CREATE_USER=project" -e "CREATE_USER_PASSWD=project_pass" -e "BACKUP_DB=project" -e "PSQL_SCRIPTS=/init_scripts/Schema00_DDL.sql;/init_scripts/Schema01_DDL.sql" geographica/postgis:postgresql-9.5.0-postgis-2.2.1-gdal-2.0.2-patched
