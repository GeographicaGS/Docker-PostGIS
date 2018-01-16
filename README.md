# Geographica's PostgreSQL / PostGIS Docker Images

This repository contains Docker image builds for PostgreSQL / PostGIS made by Geographica. This is the general README, please check version READMEs in the correponding folders.

The philosophy behind Git / Docker tags correlation we ended up using is simple: the master branch of this repo contains as many folders containing different Docker image builds as Docker tags we like to have. We don't use Git tags nor branches to try to correlate with Docker tags. We try this in the past and was a mess. Each version packages makes a folder, each folder builds a __geographica/postgis__ Docker tag bundling different library versions.


## Quick Tags Overview

Please refer to each tag README.md for full details. To get a quick overview over tags capabilities:


- [__Pleasant_Yacare:__](Pleasant_Yacare) released 2018-01-16. PostgreSQL 10.1, PostGIS 2.4.3, GEOS 3.6.2, GDAL 2.2.3, patched. Bleeding edge.

- [__Nimble_Newt:__](Nimble_Newt) released 2017-10-07. PostgreSQL 10.0, PostGIS 2.4.1, GEOS 3.6.0, GDAL 2.2.2, patched.

- [__Eclectic_Equidna:__](Eclectic_Equidna) released 2017-02-06. Basically an oversimplified version of Breezy Badger. Lots of features that impose an overhead has been removed. Functionality provided by those features can be easily achived by using accessory containers to perform operations on the PostGIS one.

- [__Deranged_Dingo:__](Deranged_Dingo) released 2016-12-01. PostgreSQL 9.4.10 and PostGIS 2.1.8, for legacy purposes.

- [__Chaotic_Cucumber:__](Chaotic_Cucumber) released 2016-11-28. Is a Breezy Badger with PgRouting installed.

- [__Breezy_Badger:__](Breezy_Badger) released 2016-10-10. PostgreSQL 9.6.0, PostGIS 2.3.0, GDAL 2.1.1, patched.

- [__Awkward_Aardvark:__](Awkward_Aardvark) released 2016-07-20 and last updated at 2016-10-10. PostgreSQL 9.5.4, PostGIS 2.2.3, GDAL 2.0.3, Patched.

- [__PostgreSQL-9.1.2-PostGIS-1.5.8-Patched:__](PostgreSQL-9.1.2-PostGIS-1.5.8-Patched) released a long time ago. A PG 9.1.2 with old PostGIS 1.5.8 patched for handling spanish SRS. For legacy applications.

- [__PostgreSQL-9.3.5-PostGIS-2.1.7-GDAL-1.11.2-Patched:__](PostgreSQL-9.3.5-PostGIS-2.1.7-GDAL-1.11.2-Patched) released a long time ago. A PG 9.3.5 with PostGIS 2.1.7 and support for raster, also spanish patched. Legacy.

- [__PostgreSQL-9.4.5-PostGIS-2.2.0-GDAL-2.0.1-Patched:__](PostgreSQL-9.4.5-PostGIS-2.2.0-GDAL-2.0.1-Patched) released some time ago. The same as above. Legacy.


## Common

Folder [__00-Common__](00-Common) holds commodities to be aplicable to all tags:

- __psql-docker:__ this script launch an interactive psql session using a Docker image.

## Docker Hub

[DockerHub repository link](https://hub.docker.com/r/geographica/postgis/)
