#
# PostgreSQL 9.3.5
# POSTGIS="2.1.4 r12966" GEOS="3.4.2-CAPI-1.8.2 r3921" PROJ="Rel. 4.8.0, 6 March 2012" GDAL="GDAL 1.9.2, released 2012/10/08" LIBXML="2.7.6" LIBJSON="UNKNOWN" TOPOLOGY RASTER
#
# Version: 0.0.1
FROM ubuntu:latest

MAINTAINER Alberto Asuero "alberto.asuero@geographica.gs"

RUN apt-get update && apt-get install -y build-essential gcc-4.7 python python-dev libreadline6-dev zlib1g-dev libssl-dev libxml2-dev libxslt-dev wget

RUN ["mkdir", "-p", "/usr/local/src/"]

# Build Proj4 4.8.0
WORKDIR /usr/local/src/
RUN ["wget","http://download.osgeo.org/proj/proj-4.8.0.tar.gz"]
RUN ["tar","xvzf","proj-4.8.0.tar.gz"]
WORKDIR /usr/local/src/proj-4.8.0
RUN ./configure CC='gcc-4.7 -m64' && make && make install

# Build GEOSS 3.4.2
WORKDIR /usr/local/src/
RUN ["wget","http://download.osgeo.org/geos/geos-3.4.2.tar.bz2"]
RUN ["tar","xvjf","geos-3.4.2.tar.bz2"]
WORKDIR /usr/local/src/geos-3.4.2
RUN ./configure CC='gcc-4.7 -m64' && make && make install

# Build PostgreSQL 9.3.5
WORKDIR /usr/local/src/
RUN ["wget","https://ftp.postgresql.org/pub/source/v9.3.5/postgresql-9.3.5.tar.bz2"]
RUN ["tar","xvjf","postgresql-9.3.5.tar.bz2"]
WORKDIR postgresql-9.3.5
RUN ./configure --with-python  CC='gcc-4.7 -m64'
RUN make && make install 
WORKDIR contrib
RUN make all && make install

ENV POSTGRES_PASSWD postgres
RUN groupadd postgres
RUN useradd -r postgres -g postgres
RUN echo "postgres:${POSTGRES_PASSWD}" | chpasswd -e

RUN echo 'export PATH=$PATH:/usr/local/pgsql/bin/' >> /etc/profile

RUN mkdir /home/postgres && chown postgres:postgres /home/postgres

# Build GDAL 1.11.2
WORKDIR /usr/local/src/
RUN ["wget","http://download.osgeo.org/gdal/1.11.2/gdal-1.11.2.tar.gz"]
RUN ["tar","xvxf","gdal-1.11.2.tar.gz"]
WORKDIR gdal-1.11.2
RUN ./configure --with-pg=/usr/local/pgsql/bin/pg_config CC='gcc-4.7 -m64' && make && make install

# Build PostGIS-2.1.4
WORKDIR /usr/local/src/
RUN ["wget","http://postgis.refractions.net/download/postgis-2.1.4.tar.gz"]
RUN ["tar","xvxf","postgis-2.1.4.tar.gz"]
WORKDIR postgis-2.1.4
RUN ./configure --with-pgconfig=/usr/local/pgsql/bin/pg_config CC='gcc-4.7 -m64' && make && make install

# Postinstallation clean
WORKDIR /usr/local/
RUN rm -Rf src

RUN apt-get -y install vim

# Configuration of database
RUN locale-gen en_US.UTF-8
RUN locale-gen es_ES.UTF-8

EXPOSE 5432
CMD su postgres -c 'postgres -D /data'
