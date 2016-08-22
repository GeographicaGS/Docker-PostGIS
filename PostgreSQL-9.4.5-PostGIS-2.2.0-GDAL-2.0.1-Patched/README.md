PostgreSQL 9.4.5, PostGIS 2.2.0, GDAL 2.0.1, Patched
=====================================================

__WARNING:__ This image is deprecated. Use tag __Awkward Aardvark__ instead.

This is the README.md for Docker tag __postgresql-9.4.5-postgis-2.2.0-gdal-2.0.1-patched__.

Versions
--------
This Dockerfile compiles the following software:

- __PostgreSQL 9.4.5;__

- __GEOS 3.5.0;__

- __Proj 4.9.2:__ patched with the spanish national grid for conversion between ED50 to ETRS89;

- __GDAL 2.0.1:__ also patched;

- __Postgis 2.2.0:__ patched as well.

Usage Pattern
-------------
Build the image directly from Git (this can take a while, don't forget to checkout the right branch):

```Shell
docker build -t="geographica/postgis:postgresql-9.4.5-postgis-2.2.0-gdal-2.0.1-patched" .
```
Build with another locale 
```Shell
docker build --build-arg locale=es_ES -t="geographica/postgis:postgresql-9.4.5-postgis-2.2.0-gdal-2.0.1-patched-es_ES" .
```

or pull it from Docker Hub:

```Shell
docker pull geographica/postgis:postgresql-9.4.5-postgis-2.2.0-gdal-2.0.1-patched
```

If you want an specific locale version:


The image uses several environment variables. Refer to the Dockerfile for a complete list. The most important one is __POSTGRES_PASSWD__, the password for the user POSTGRES.

The image exposes port 5432 and a volume designated by enviroment variable __POSTGRES_DATA_FOLDER__. 
## Dev environment
For dev environment you can run:
```Shell
docker run -p 5432:5432 --name postgis-2.2 geographica/postgis:postgresql-9.4.5-postgis-2.2.0-gdal-2.0.1-patched 
```

## Production enviroment

```Shell
docker run -d -P --name whatever -e "POSTGRES_PASSWD="md5"$(printf '%s' "change_this_password" "postgres" | md5sum | cut -d ' ' -f 1)" geographica/postgis:postgresql-9.4.5-postgis-2.2.0-gdal-2.0.1-patched 
```

This generates a MD5 hashed password for the user __postgres__. Keep in mind that to provide a MD5-hashed password to PostgreSQL it has to be the hash of __passwordusername__ and be prefixed by __md5__.

The image creates containers that initializes automatically a datastore, setting the password for user __postgres__. 

## Data containers
If you're going to use it at production or dev, we recommend you to create a data container to store the persistent data. 
```Shell
docker create --name postgis-2.2_data -v /data ubuntu:trusty /bin/false

```
After you can import the data volumes using --volumes-from
```Shell
docker run -p 5432:5432 --name postgis-2.2 -d --volumes-from postgis-2.2_data geographica/postgis:postgresql-9.4.5-postgis-2.2.0-gdal-2.0.1-patched-es_ES
``


