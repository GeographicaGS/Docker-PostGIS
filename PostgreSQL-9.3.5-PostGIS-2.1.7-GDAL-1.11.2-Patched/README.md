PostgreSQL 9.3.5, PostGIS 2.1.7, GDAL 1.11.2, Patched
=====================================================

__WARNING:__ This image is deprecated. Use tag __Awkward Aardvark__ instead.

Versions
--------
This Dockerfile compiles the following software:

- __PostgreSQL 9.3.5;__

- __GEOS 3.4.2;__

- __Proj 4.9.1:__ patched with the spanish national grid for conversion between ED50 to ETRS89;

- __GDAL 1.11.2:__ also patched;

- __Postgis 2.1.7:__ patched as well, and with topology support.

Usage Pattern
-------------
Build the image directly from Git (this can take a while, don't forget to checkout the right branch):

```Shell
cd gitfolder

docker build -t="geographica/postgis:postgresql-9.3.5-postgis-2.1.7-gdal-1.11.2-patched" .
```

or pull it from Docker Hub:

```Shell
docker pull geographica/postgis:postgresql-9.3.5-postgis-2.1.7-gdal-1.11.2-patched
```

The image uses several environment variables. Refer to the Dockerfile for a complete list. The most important one is __POSTGRES_PASSWD__, the password for the user POSTGRES.

The image exposes port 5432 and a volume designated by enviroment variable __POSTGRES_DATA_FOLDER__. In a production enviroment, create containers this way:

```Shell
export PGPASSWD="md5"$(printf '%s' "password_here" "postgres" | md5sum | cut -d ' ' -f 1) && \
docker run -d -P --name ageworkshoptestpg -e "POSTGRES_PASSWD=${PGPASSWD}" \
geographica/postgis:postgresql-9.3.5-postgis-2.1.7-gdal-1.11.2-patched 
```

This generates a MD5 hashed password for the user __postgres__, hidden even to the _docker inspect_ command. Keep in mind that to provide a MD5-hashed password to PostgreSQL it has to be the hash of __passwordusername__ and be prefixed by __md5__.

The image creates containers that initializes automatically a datastore, setting the password for user __postgres__. 


Executing psql Scripts on Start Up
----------------------------------
The image can run psql scripts on container's start up. To do so, put scripts inside the container (via a child container image that ADD them from the Dockerfile or mounting a volume) and configure the __PSQL_SCRIPTS__ environment variable. This variable can contain full paths to psql scripts separated by semicolons (;) that will be executed in order on container startup. For example:

```Shell
export PGPASSWD="md5"$(printf '%s' "password_here" "postgres" | md5sum | cut -d ' ' -f 1) && \
docker run -d -P --name ageworkshoptestpg -e "POSTGRES_PASSWD=${PGPASSWD}" \
-v /localscripts/:/psql_scripts/ \
-e "PSQL_SCRIPTS=/psql_scripts/script1.sql;/psql_scripts/script2.sql" \
geographica/postgis:postgresql-9.3.5-postgis-2.1.7-gdal-1.11.2-patched 
```

_script1.sql_ and _script2.sql_ will be executed on container startup.


Killing the Container
---------------------
This container will handle signals send to it with _docker kill_ properly, so the database is shut down proper and tidily. Thus:

- __SIGTERM__ signals for a smart shutdown, waiting for all connections and transactions to be finished. The server won't allow for new connections, thou:

```Shell
pg_ctl -D . stop -m smart

docker kill -s SIGTERM containername
```

- __SIGINT__ signals for fast shutdown. The server will abort current transactions and disconnect users, but will exit nicely otherwise;

```Shell
pg_ctl -D . stop -m fast

docker kill -s SIGINT containername
```

- __SIGQUIT__ signals for immediate shutdown. This will leave the database in a improper state and lead to recovery on next startup:

```Shell
pg_ctl -D . stop -m immediate

docker kill -s SIGQUIT containername
```
