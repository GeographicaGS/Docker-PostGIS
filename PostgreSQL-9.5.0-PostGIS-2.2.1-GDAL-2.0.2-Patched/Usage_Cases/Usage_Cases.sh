#!/bin/bash

# The simplest, for basic debugging

docker run -ti --rm --name "test" -P geographica/postgis:postgresql-9.5.0-postgis-2.2.1-gdal-2.0.2-patched


# Test restarts

# docker run -d -p 5440:5432 --name "test" -e "LOCALE=ru_RU" -e "CREATE_USER=project" -e "CREATE_USER_PASSWD=project_pass" geographica/postgis:postgresql-9.5.0-postgis-2.2.1-gdal-2.0.2-patched





# docker run -ti --rm -P -e "LOCALE=ru_RU" -e "CREATE_USER=project" -e "CREATE_USER_PASSWD=project_pass" geographica/postgis:postgresql-9.5.0-postgis-2.2.1-gdal-2.0.2-patched

# docker run -ti --rm -P -e "CREATE_USER=project" -e "CREATE_USER_PASSWD=project_pass" geographica/postgis:postgresql-9.5.0-postgis-2.2.1-gdal-2.0.2-patched

# docker run -ti --rm --entrypoint /bin/bash -v /home/git/Docker-Postgis/PostgreSQL-9.5.0-PostGIS-2.2.1-GDAL-2.0.2-Patched/:/docker-volume -P geographica/postgis:postgresql-9.5.0-postgis-2.2.1-gdal-2.0.2-patched

# export PGPASSWD="md5"$(printf '%s' "new_password_here" "postgres" | md5sum | cut -d ' ' -f 1) && docker run -ti --rm -e "POSTGRES_PASSWD=${PGPASSWD}" -P geographica/postgis:postgresql-9.5.0-postgis-2.2.1-gdal-2.0.2-patched 

# docker run -ti --rm -P -v /home/git/Docker-Postgis/PostgreSQL-9.5.0-PostGIS-2.2.1-GDAL-2.0.2-Patched/container_creation_examples/SQL_Scripts:/init_scripts -e "LOCALE=es_ES" -e "CREATE_USER=project" -e "CREATE_USER_PASSWD=project_pass" -e "BACKUP_DB=project" -e "PSQL_SCRIPTS=/init_scripts/Schema00_DDL.sql;/init_scripts/Schema01_DDL.sql" geographica/postgis:postgresql-9.5.0-postgis-2.2.1-gdal-2.0.2-patched
