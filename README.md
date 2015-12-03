Geographica's PostgreSQL / PostGIS Docker Images
================================================

This repository contains Docker image builds for PostgreSQL / PostGIS made by Geographica. This is the general README, please check version READMEs in the correponding folders.

The philosophy behind Git / Docker tags correlation we ended up using is simple: the master branch of this repo contains as many folders containing different Docker image builds as Docker tags we like to have. We don't use Git tags nor branches to try to correlate with Docker tags. We try this in the past and was a mess. Each version packages makes a folder, each folder builds a __geographica/postgis__ Docker tag bundling different library versions.
