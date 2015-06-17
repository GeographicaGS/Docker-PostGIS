#
# PostgreSQL 9.4.4
# POSTGIS=2.1.7 GEOS=3.4.2 PROJ=4.9.1 GDAL=GDAL 1.11.2 LIBXML=2.7.6 LIBJSON TOPOLOGY RASTER
#
# Version: 0.0.1
FROM ubuntu:14.04

MAINTAINER Alberto Asuero "alberto.asuero@geographica.gs"

RUN apt-get update && apt-get install -y build-essential gcc-4.7 python python-dev libreadline6-dev zlib1g-dev libssl-dev libxml2-dev libxslt-dev wget

RUN ["mkdir", "-p", "/usr/local/src/"]

# Build Proj4 4.9.1
WORKDIR /usr/local/src/
RUN wget http://download.osgeo.org/proj/proj-4.9.1.tar.gz && tar xvzf proj-4.9.1.tar.gz
WORKDIR /usr/local/src/proj-4.9.1
RUN ./configure CC='gcc-4.7 -m64' && make && make install

# Build GEOSS 3.4.2
WORKDIR /usr/local/src/
RUN wget http://download.osgeo.org/geos/geos-3.4.2.tar.bz2 && tar xvjf geos-3.4.2.tar.bz2
WORKDIR /usr/local/src/geos-3.4.2
RUN ./configure CC='gcc-4.7 -m64' && make && make install

# Build PostgreSQL 9.4.4
WORKDIR /usr/local/src/
RUN wget https://ftp.postgresql.org/pub/source/v9.4.4/postgresql-9.4.4.tar.bz2 && tar xvjf postgresql-9.4.4.tar.bz2
WORKDIR postgresql-9.4.4
RUN ./configure --prefix=/usr/local  --with-python  CC='gcc-4.7 -m64'&& make && make install 
WORKDIR contrib
RUN make all && make install

ENV POSTGRES_PASSWD postgres
RUN groupadd postgres && useradd -r postgres -g postgres && echo "postgres:${POSTGRES_PASSWD}" | chpasswd -e && echo 'export PATH=$PATH:/usr/local/pgsql/bin/' >> /etc/profile && mkdir /home/postgres && chown postgres:postgres /home/postgres

# Build GDAL 1.11.2
WORKDIR /usr/local/src/
RUN wget http://download.osgeo.org/gdal/1.11.2/gdal-1.11.2.tar.gz && tar xvxf gdal-1.11.2.tar.gz
WORKDIR gdal-1.11.2
RUN ./configure  CC='gcc-4.7 -m64' && make && make install && ldconfig

# Build PostGIS-2.1.7
WORKDIR /usr/local/src/
RUN wget http://download.osgeo.org/postgis/source/postgis-2.1.7.tar.gz && tar xvxf postgis-2.1.7.tar.gz
WORKDIR postgis-2.1.7
RUN ./configure --with-raster --with-topology CC='gcc-4.7 -m64' && make && make install

# Postinstallation 
WORKDIR /usr/local/
RUN rm -Rf src && locale-gen en_US.UTF-8 && locale-gen es_ES.UTF-8 && ldconfig

EXPOSE 5432

ENV PATH "/usr/local/pgsql:$PATH"

CMD su postgres -c 'postgres -D /data'
