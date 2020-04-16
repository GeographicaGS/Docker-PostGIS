#!/bin/bash
set -ex

docker build \
    --pull \
    -t geographica/postgis:unbiased_uakari_raster \
    .
