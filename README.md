Docker Image for PostgreSQL / PostGIS
=====================================

This is the README.md for Docker tag __postgresql-9.3.5-postgis-2.1.7-gdal-1.11.2-Patched__. Please refer to the __Master__ README.md for updated information.

Why?
----
Because:

- we want to reach a minimum level of proficiency with Docker, a wonderful technology new to us;

- to support legacy systems using old PostgreSQL / PostGIS deployments.

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

- __postgresql-9.1.2-postgis-1.5.8:__ PostgreSQL 9.1.2, PROJ 4.8.0, GEOS 3.4.2, PostGIS 1.5.8, compliled from source, plus PROJ patched with the spanish ED50-ETRS89 datum shifting national grid;

- __postgresql-9.3.5-postgis-2.1.4-gdal-1.9.2:__ PostgreSQL 9.3.5, PROJ 4.8.0, GEOS 3.4.2, GDAL 1.9.2, PostGIS 2.1.4, compiled from source, without spanish patch;

- __postgresql-9.3.5-postgis-2.1.7-gdal-1.11.2-Patched:__ PostgreSQL 9.3.5, PROJ 4.9.1, GEOS 3.4.2, GDAL 1.11.2, PostGIS 2.1.7, compiled from source, with spanish patch;

- __postgresql-9.4.4-postgis-2.1.7-gdal-1.11.2:__ PostgreSQL 9.4.4, PROJ 4.9.1, GEOS 3.4.2, GDAL 1.11.2, PostGIS 2.1.7, compiled from source, without spanish patch.

Guidelines for Creating New Docker Tags in this Repository
----------------------------------------------------------
Each Docker tag in this repository addresses changes in library versions bundled together. Follow this guidelines when creating new Docker tags for this repo:

- to create and maintain new Docker tags, make a GIT branch with a descriptive name. Each tag must match its branch in name. Do not use GIT tags to support Docker tags, for branches does exactly the same job and does it better in this case. Never destroy those branches and keep them open;

- the master branch should reflect the most updated README.md. This means that the master branch may not point to the most "advanced" branch in terms of library versions. But always refer to the master README.md for the most updated information;

- don't forget to document detailed information about the new GIT branch / Docker tag in the former section;

- don't forget to update the first line of this README.md warning about the README.md version to tell the user about the README.md being read.

Usage Pattern
-------------
Check Dockerfile for important environmental variables.

Build the image directly from Git (this can take a while, don't forget to checkout the right branch):

```Shell
git checkout tagbranch

docker build -t="geographica/postgis:postgresql-9.3.5-postgis-2.1.7-gdal-1.11.2-Patched" .
```

or pull it from Docker Hub:

```Shell
docker pull geographica/postgis:postgresql-9.3.5-postgis-2.1.7-gdal-1.11.2-Patched
```

Create a folder in the host to contain the data storage. Alternatively, data can be stored inside the container at /data. On a general basis, we like to persist the data storage in the host and not in the container:

```Shell
mkdir /whatever/postgresql-X.X.X-postgis-X.X.X-data
```

Then create a temporary container to initialize the data store structure. In the container, /data will be always the data storage. If the data are to be created inside the container itself, don't create a temporary container, creating the final container itself without any volumes and performing the data storage steps on /data:

```Shell
docker run -ti --rm -v /whatever/postgresql-X.X.X-postgis-X.X.X-data:/data/ geographica/postgis:postgresql-9.3.5-postgis-2.1.7-gdal-1.11.2-Patched /bin/bash

chown postgres:postgres /data

chmod 700 /data

su postgres -c "initdb --encoding=UTF-8 --locale=es_ES.UTF-8 --lc-collate=es_ES.UTF-8 --lc-monetary=es_ES.UTF-8 --lc-numeric=es_ES.UTF-8 --lc-time=es_ES.UTF-8 -D /data"
```

Now, create the real container. For example:

```Shell
docker run -ti --name="pgsql-X.X.X-postgis-X.X.X" -p 5455:5432 -v /whatever/postgresql-X.X.X-postgis-X.X.X-data:/data/ -v /whatever/csv_and_other_data-folder/:/whatever_matches_in_container/ geographica/postgis:postgresql-9.3.5-postgis-2.1.7-gdal-1.11.2-Patched
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

Modify access in the new data storage (either on the host or inside the container). In __pg_hba.conf__, add universal access from any IP:

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
docker run -it --rm -v /whatever/postgresql-X.X.X-postgis-X.X.X-data/:/data/ -p 5455:5432 geographica/postgis:postgresql-9.3.5-postgis-2.1.7-gdal-1.11.2-Patched /bin/bash
```

and start the server manually:

```Shell
su postgres -c "pg_ctl -D /data start"
```

Now you can use __psql__ inside the container. Keep in mind that interactive use is the only way of performing certain tasks, like for example running scripts that search for __.csv__ files in the filesystem for data restoration. Mount a
volume to the directory containing the __.csv__ dumps and use __\copy__ in __psql__ scripts for improved portability, but those files must be local to the container.
