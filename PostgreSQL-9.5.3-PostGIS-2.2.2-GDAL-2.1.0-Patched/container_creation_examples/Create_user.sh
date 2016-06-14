#!/bin/bash

# docker run -ti --rm -P -e "LOCALE=es_ES" -e "CREATE_USER=project" -e "CREATE_USER_PASSWD=project_pass" geographica/postgis:postgresql-9.5.0-postgis-2.2.1-gdal-2.0.2-patched

docker run -ti --rm -P -e "CREATE_USER=project" -e "CREATE_USER_PASSWD=project_pass" geographica/postgis:postgresql-9.5.0-postgis-2.2.1-gdal-2.0.2-patched
