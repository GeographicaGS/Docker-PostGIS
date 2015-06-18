#Docker PostGIS

##Why?

Because:

- we want to reach a minimum level of proficiency with Docker, a wonderful
    technology new to us;

- it's a developing and production environment setting we based a lot of
    projects on in the past, and we still use it in mantienance tasks.

##What does this Docker image contains?

Compiled from source, this is what this image contains:

  - PostgreSQL 9.4.4
  - PROJ 4.9.1
  - GEOS 3.4.2
  - PostGIS 2.1.7
  - Gdal-1.11.2
  
##Usage Pattern

Build the image directly from GitHub (this can take a while):
```
docker build -t=geographica/postgis:postgresql-9.4.4-postgis-2.1.7-gdal-1.11.2 https://github.com/GeographicaGS/Docker-PostgreSQL-9.1.2-PostGIS-2.1.7.git
```

or pull it from Docker Hub:
```
docker pull geographica/postgis:postgresql-9.4.4-postgis-2.1.7-gdal-1.11.2
```

or:
```
docker build -t=geographica/postgis:postgresql-9.4.4-postgis-2.1.7-gdal-1.11.2 .
```

Create a folder in the host to contain the data storage. We like to persist the
data storage in the host and not in the container:
```
mkdir /whatever/postgresql-9.4.4-postgis-2.1.7-gdal-1.11.2
```

Then create a temporary container to create the data storage. In the container,
/data will be always the data storage:

```
docker run --rm -v /whatever/postgresql-9.4.4-postgis-2.1.7-gdal-1.11.2:/data -t -i geographica/postgis:postgresql-9.4.4-postgis-2.1.7-gdal-1.11.2 /bin/bash

chown postgres:postgres /data

chmod 700 /data

su postgres -c "initdb --encoding=UTF-8 -D /data"
```

Modify access in the new data storage. In __pg_hba.conf__, add universal access
from any IP:
```
host    all             all             0.0.0.0/0               trust
```
Modify also the data storage to listen to all IP. In __postgresql.conf__,
modify:
```
listen_addresses = '*'
```


Now we can exit the temporary container and create a new one that will use this
data storage:

    
```
docker run -i -t --name="postgresql-9.4.4-postgis-2.1.7-gdal-1.11.2" -v /whatever/postgresql-9.4.4-postgis-2.1.7-gdal-1.11.2:/data/ -p 5455:5432 geographica/postgis:postgresql-9.4.4-postgis-2.1.7-gdal-1.11.2
```

In the case of complex database deployment scripts that uses data in CSV files,
for example, don't forget to make the containing folder available to the
container, for the server in it has to be able to see the files, not just the
local psql process. For example:
```
docker run -p 5454:5432 --name postgres-elcano -v /home/malkab/postgresql-9.4.4-postgis-2.1.7-gdal-1.11.2-data/:/data/ -v /home/git/Elcano-iepg/database/:/home/git/Elcano-iepg/database/ -i -t geographica/postgis:postgresql-9.4.4-postgis-2.1.7-gdal-1.11.2
```

in this case, __-i__ and __-t__ are used so the container and the database can
be stoped with Ctrl-C without __docker kill__ (I may be wrong, but I think this
is a cleaner way to exit the container, since the data storage will be properly
shut down).

This container will be permanent and we can start and attach to it in the usual
way:

```
docker start postgresql-9.4.4-postgis-2.1.7-gdal-1.11.2

docker attach postgresql-9.4.4-postgis-2.1.7-gdal-1.11.2
```
The server can be accessed the usual way, at port 5455:
```
    psql -h localhost -p 5455 -U postgres postgres
```
Also an interactive use of the image is possible, if you need for example access
to __psql__ because you don't have one installed in the host:

```
    docker run -i -t --rm -v /whatever/postgresql-9.4.4-postgis-2.1.7-gdal-1.11.2-data/:/data/ -p 5455:5432
    geographica/postgis:postgresql-9.4.4-postgis-2.1.7-gdal-1.11.2 /bin/bash
```
and start the server manually:

```
    su postgres -c "pg_ctl -D /data start"
```

Now you can use __psql__ inside the container. Keep in mind that interactive use
is the only way of performing certain tasks, like for example running scripts
that search for __.csv__ files in the filesystem for data restoration. Mount a
volume to the directory containing the __.csv__ dumps and use __\copy__ in
__psql__ scripts for improved portability, but those files must be local to the
container.