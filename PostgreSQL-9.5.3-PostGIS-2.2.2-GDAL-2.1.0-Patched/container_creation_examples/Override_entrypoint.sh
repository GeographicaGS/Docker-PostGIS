#!/bin/bash

docker run -ti --rm --entrypoint /bin/bash -v /home/git/Docker-Postgis/PostgreSQL-9.5.0-PostGIS-2.2.1-GDAL-2.0.2-Patched/:/docker-volume -P geographica/postgis:postgresql-9.5.0-postgis-2.2.1-gdal-2.0.2-patched
