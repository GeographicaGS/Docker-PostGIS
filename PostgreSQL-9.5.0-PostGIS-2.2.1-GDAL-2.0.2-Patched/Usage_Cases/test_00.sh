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

docker run -ti --name "test_00" -P --entrypoint /bin/bash \
       geographica/postgis:postgresql-9.5.0-postgis-2.2.1-gdal-2.0.2-patched

