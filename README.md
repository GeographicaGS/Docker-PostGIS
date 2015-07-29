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
- PROJ.4, patched to support the NTv2 Spanish national grid for datum shiftings between ED50 and ETRS89;
- GEOS;
- PostGIS, also patched to support the spanish national grid.

Versions
--------
Each version combination is a branch in GitHub and a tag in Docker Hub. These are the available versions:

- __postgresql-9.1.2-postgis-1.5.8:__ PostgreSQL 9.1.2, PROJ 4.8.0, GEOS 3.4.2, PostGIS 1.5.8, compliled from source, plus PROJ patched with the spanish ED50-ETRS89 datum shifting national grid;

- __postgresql-9.3.5-postgis-2.1.4-gdal-1.9.2:__ PostgreSQL 9.3.5, PROJ 4.8.0, GEOS 3.4.2, GDAL 1.9.2, PostGIS 2.1.4, compiled from source, without spanish patch;

- __postgresql-9.3.5-postgis-2.1.7-gdal-1.11.2-Patched:__ PostgreSQL 9.3.5, PROJ 4.9.1, GEOS 3.4.2, GDAL 1.11.2, PostGIS 2.1.7, compiled from source, with spanish patch;

- __postgresql-9.4.4-postgis-2.1.7-gdal-1.11.2:__ PostgreSQL 9.4.4, PROJ 4.9.1, GEOS 3.4.2, GDAL 1.11.2, PostGIS 2.1.7, compiled from source, without spanish patch.

Guidelines for Creating New Docker Tags in this Repository
----------------------------------------------------------
Each Docker tag in this repository addresses changes in library versions bundled together. Follow this guidelines when creating new Docker tags for this repo:

- don't modify any branch that you aren't the manager of (see Dockerfile's MAINTAINER);

- to create new DockerHub tags, make a GIT branch with a descriptive name. Each DockerHub tag must match its branch in name;

- the master branch should reflect the most updated README.md. This means that the master branch may not point to the most "advanced" branch in terms of library versions. But always refer to the master README.md for the most updated information;

- don't forget to document detailed information about the new branch / tag in the former section;

- don't forget to update the first line of this README.md warning about the README.md version to tell the user about the README.md being read;

- don't forget to push the tag to DockerHub with exactly the same name as the branch containing its build code;

- don't use Git tags. In this case, branches perform the same objective with less hassle.

Usage Pattern
-------------
Build the image directly from Git (this can take a while, don't forget to checkout the right branch):

```Shell
cd gitfolder

git checkout rightbranch

docker build -t="geographica/postgis:postgresql-9.3.5-postgis-2.1.7-gdal-1.11.2-Patched" .
```

or pull it from Docker Hub:

```Shell
docker pull geographica/postgis:postgresql-9.3.5-postgis-2.1.7-gdal-1.11.2-Patched
```

The image uses several environment variables. Refer to the Dockerfile for a complete list. The most important one is __POSTGRES_PASSWD__, the password for the user POSTGRES.

The image exposes port 5432 and a volume designated by enviroment variable __POSTGRES_DATA_FOLDER__. In a production enviroment, create containers this way:

```Shell
docker run -d -P -e "POSTGRES_PASSWD="md5"$(printf '%s' "passwordpostgres" | md5sum | cut -d ' ' -f 1)" geographica/postgis:postgresql-9.3.5-postgis-2.1.7-gdal-1.11.2-Patched
```

This generates a MD5 hashed password for the user __postgres__.

The image creates containers that initializes automatically a datastore, setting the password for user __postgres__. 
