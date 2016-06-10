#!/bin/bash

# Sets the base folder to mount volumes for testing
HOST_BASE=/home/malkab/Desktop/Docker_PostGIS_Tests

rm -Rf $HOST_BASE


docker stop test_00
docker stop test_01
docker stop test_02
docker stop test_03
docker stop test_04
docker stop test_05
docker stop test_06


docker rm -v test_00
docker rm -v test_01
docker rm -v test_02
docker rm -v test_03
docker rm -v test_04
docker rm -v test_05
docker rm -v test_06

