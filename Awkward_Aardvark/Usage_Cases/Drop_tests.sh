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
docker stop test_07
docker stop test_08_a
docker stop test_08_b
docker stop test_10
docker stop test_11


docker rm -v test_00
docker rm -v test_01
docker rm -v test_02
docker rm -v test_03
docker rm -v test_04
docker rm -v test_05
docker rm -v test_06
docker rm -v test_07
docker rm -v test_08_pgdata
docker rm -v test_08_a
docker rm -v test_08_b
docker rm -v test_10
docker rm -v test_11

userdel -r thedockeruser
groupdel thedockergroup
