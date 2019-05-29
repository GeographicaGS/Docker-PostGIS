#!/bin/bash
set -ex

docker build \
    --pull \
    -t geographica/postgis:dev \
    .
