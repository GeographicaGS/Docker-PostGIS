FROM ubuntu:trusty

MAINTAINER Alberto Asuero "alberto@geographica.gs"

ARG locale=en_US

# Environment
ENV POSTGRES_PASSWD postgres 
ENV ROOTDIR /usr/local/ 
ENV POSTGRES_DATA_FOLDER /data 
ENV PG_VERSION 9.4.5
ENV GEOS_VERSION 3.5.0
ENV PROJ4_VERSION 4.9.2 
ENV POSTGIS_VERSION 2.2.0
ENV GDAL_VERSION 2.0.1
ENV LOCALE ${locale}
ENV ENCODING UTF-8
ENV LANG ${LOCALE}.${ENCODING}

# Load assets
WORKDIR $ROOTDIR/
ADD https://ftp.postgresql.org/pub/source/v${PG_VERSION}/postgresql-${PG_VERSION}.tar.bz2 $ROOTDIR/src/
ADD http://download.osgeo.org/geos/geos-${GEOS_VERSION}.tar.bz2 $ROOTDIR/src/
ADD http://download.osgeo.org/proj/proj-${PROJ4_VERSION}.tar.gz $ROOTDIR/src/
ADD packages/proj4-patch/src/pj_datums.c $ROOTDIR/src/
ADD http://download.osgeo.org/proj/proj-datumgrid-1.5.tar.gz $ROOTDIR/src/
ADD packages/proj4-patch/nad/epsg $ROOTDIR/src/
ADD packages/proj4-patch/nad/PENR2009.gsb $ROOTDIR/src/
ADD http://download.osgeo.org/postgis/source/postgis-${POSTGIS_VERSION}.tar.gz $ROOTDIR/src/
ADD packages/postgis-patch/spatial_ref_sys.sql $ROOTDIR/src/
ADD http://download.osgeo.org/gdal/2.0.1/gdal-${GDAL_VERSION}.tar.gz $ROOTDIR/src/
ADD packages/compile.sh $ROOTDIR/src/
ADD packages/run /usr/local/bin/

# Compilation
RUN chmod 777 src/compile.sh

RUN src/compile.sh --encoding ${ENCODING} --locale ${LOCALE} --pg-version ${PG_VERSION} --geos-version ${GEOS_VERSION} \
  --proj4-version ${PROJ4_VERSION} --postgis-version ${POSTGIS_VERSION} --gdal-version ${GDAL_VERSION}

# Final touches
EXPOSE 5432

# Volumes
VOLUME $POSTGRES_DATA_FOLDER

CMD /usr/local/bin/run