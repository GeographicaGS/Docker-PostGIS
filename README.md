Docker Images for PostgreSQL / PostGIS
======================================

This repository contains several dockerized version combinations of PostgreSQL, Proj.4, GEOS, PostGIS, and GDAL, most of them compiled from source.

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

- GDAL;

- PostGIS, also patched to support the spanish national grid.

Versions
--------
Refer to each folder for detailed notes about the given version configurations.

Guidelines for Creating New Docker Tags in this Repository
----------------------------------------------------------
When a new version combination is needed, just create a self-contained folder with everything needed in it. Just leave at root level this README, but provide a custom README for each combination.
