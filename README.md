Docker Images for PostgreSQL / PostGIS
======================================

This repository contains several dockerized version combinations of PostgreSQL, Proj.4, GEOS, PostGIS, and GDAL, most of them compiled from source.

Branches of version combinations are about to be deprecated. No longer are GIT branches to be used to manage different version combinations, from now hereafter a folder will be created to store all information about each combination.

Why?
----
Because:

- we want to reach a minimum level of proficiency with Docker, a wonderful technology new to us;

- to support legacy systems using old PostgreSQL / PostGIS deployments.

What does those Docker images contain?
--------------------------------------
Usually compiled from source, this repository contains several combinations of versions of the following software:

- PostgreSQL;

- PROJ.4, patched to support the NTv2 Spanish national grid for datum shiftings between ED50 and ETRS89;

- GEOS;

- GDAL, also patched;

- PostGIS, patched.

Versions
--------
Refer to each folder for detailed notes about the given version configurations.

Guidelines for Creating New Docker Tags in this Repository
----------------------------------------------------------
When a new version combination is needed, just create a self-contained folder with everything needed in it. Just leave at root level this README, but provide a custom README for each combination.
