#!/bin/bash
set -ex

docker build \
    --pull \
    -t geographica/postgis:tasty_termite \
    .
