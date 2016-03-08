#!/bin/bash

export PGPASSWD="md5"$(printf '%s' "new_password_here" "postgres" | md5sum | cut -d ' ' -f 1) && docker run -ti --rm -e "POSTGRES_PASSWD=${PGPASSWD}" -P geographica/postgis:postgresql-9.5.0-postgis-2.2.1-gdal-2.0.2-patched 
