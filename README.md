Docker Image for PostgreSQL / PostGIS
=====================================

This is the README.md for version __2015-06-08__. Please refer to the __Master__ README.md for updated information.

Why?
----
Because:

  - we want to reach a minimum level of proficiency with Docker, a wonderful technology new to us;

  - it's a developing and production environment setting we based a lot of projects on in the past, and we still use it in mantienance tasks.

What does this Docker image contains?
-------------------------------------
Compiled from source, this is what this image contains, in different versions:

  - PostgreSQL;
  - PROJ, patched to support the NTv2 Spanish national grid for datum shiftings between ED50 and ETRS89;
  - GEOS;
  - PostGIS, also patched to support the spanish national grid.

Versions
--------
Each version combination is a tag and a branch in GitHub, and a tag in Docker Hub. These are the available versions:

- __2015-06-03:__ PostgreSQL 9.1.2, Proj 4.8.0, GEOS 3.4.2, and PostGIS 1.5.8;
- __2015-06-08:__ PostgreSQL 9.3.5, Proj 4.9.1, GEOS 3.4.2, GDAL 1.11.2, and PostGIS 2.1.7

Usage Pattern
-------------
Check Dockerfile for important environmental variables.

Build the image directly from GitHub (this can take a while):

```Shell
docker build -t="geographica/postgresql-postgis-spanish-patch:2015-06-03" https://github.com/GeographicaGS/Docker-PostgreSQL-PostGIS-Spanish_Patch.git
```

or pull it from Docker Hub:

```Shell
docker pull geographica/postgresql-postgis-spanish-patch:2015-06-03
```

Create a folder in the host to contain the data storage. We like to persist the data storage in the host and not in the container:

```Shell
mkdir /whatever/postgresql-X.X.X-postgis-X.X.X-data
```

Then create a temporary container to initialize the data store structure. In the container, /data will be always the data storage:

```Shell
docker run -ti --rm -v /whatever/postgresql-X.X.X-postgis-X.X.X-data:/data/ geographica/postgresql-postgis-spanish-patch:2015-06-03 /bin/bash

chown postgres:postgres /data

chmod 700 /data

su postgres -c "initdb --encoding=UTF-8 --locale=es_ES.UTF-8 --lc-collate=es_ES.UTF-8 --lc-monetary=es_ES.UTF-8 --lc-numeric=es_ES.UTF-8 --lc-time=es_ES.UTF-8 -D /data"
```

Now, create the real container. In the case of complex database deployment scripts that uses data in CSV files, for example, don't forget to make the containing folder available to the container, for the server in it has to be able to see the files, not just the local psql process. For example:

```Shell
docker run -ti --name="pgsql-X.X.X-postgis-X.X.X" -p 5455:5432 -v /whatever/postgresql-X.X.X-postgis-X.X.X-data:/data/ -v /whatever/csv_and_other_data-folder/:/whatever_matches_in_container/ geographica/postgresql-postgis-spanish-patch:2015-06-03
```

in this case, __-i__ and __-t__ are used so the container and the database can be stoped with Ctrl-C without __docker kill__ (I may be wrong, but I think this is a cleaner way to exit the container, since the data storage will be properly shut down).

This container will be permanent and we can start, stop, and attach to it in the usual way:

```Shell
docker start pgsql-X.X.X-postgis-X.X.X

docker attach pgsql-X.X.X-postgis-X.X.X

docker stop pgsql-X.X.X-postgis-X.X.X
```

Reattach a console to it to make internal changes:

```Shell
docker exec -ti pgsql-X.X.X-postgis-X.X.X /bin/bash

```

For example, in PostGIS version 1.5, it is imperative to enter into the container this way to have access to the scripts that creates the PostGIS extension from a __psql__ session inside the container.

Modify access in the new data storage. In __pg_hba.conf__, add universal access from any IP:

```Shell
host    all             all             0.0.0.0/0               trust
```

Modify also the data storage to listen to all IP. In __postgresql.conf__, modify:

```Shell
listen_addresses = '*'
```

The server can be accessed the usual way, at port 5455:

```Shell
psql -h localhost -p 5455 -U postgres postgres
```

Also an interactive use of the image is possible, if you need for example access to __psql__ because you don't have one installed in the host:

```Shell
docker run -it --rm -v /whatever/postgresql-X.X.X-postgis-X.X.X-data/:/data/ -p 5455:5432 geographica/postgresql-postgis-spanish-patch:2015-06-03 /bin/bash
```

and start the server manually:

```Shell
su postgres -c "pg_ctl -D /data start"
```

Now you can use __psql__ inside the container. Keep in mind that interactive use is the only way of performing certain tasks, like for example running scripts that search for __.csv__ files in the filesystem for data restoration. Mount a
volume to the directory containing the __.csv__ dumps and use __\copy__ in __psql__ scripts for improved portability, but those files must be local to the container.
