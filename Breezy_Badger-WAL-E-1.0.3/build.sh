#!/bin/bash

docker build -t=geographica/postgis:breezy_badger-wal-e --build-arg WAL_TIMEOUT=${WAL_TIMEOUT} .
