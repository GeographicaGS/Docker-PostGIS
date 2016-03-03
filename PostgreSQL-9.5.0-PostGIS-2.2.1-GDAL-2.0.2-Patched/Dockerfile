FROM ubuntu:latest

MAINTAINER Juan Pedro Perez "jp.alcantara@geographica.gs"


# Environment
ENV POSTGRES_PASSWD postgres
ENV ROOTDIR /usr/local/
ENV POSTGRES_DATA_FOLDER /data
ENV PG_VERSION 9.5.0
ENV GEOS_VERSION 3.5.0
ENV PROJ4_VERSION 4.9.2
ENV POSTGIS_VERSION 2.2.1
ENV GDAL_VERSION 2.0.2
ENV CGAL_VERSION 4.6.3
ENV SFCGAL_VERSION 1.3.0
ENV ENCODING UTF-8
ENV LOCALE es_ES
ENV LANG ${LOCALE}.${ENCODING}
ENV PSQL_SCRIPTS /usr/local/Dummy_psql_command.sql;/usr/local/Dummy_psql_command.sql


# Load assets
WORKDIR $ROOTDIR/
ADD packages/Dummy_psql_command.sql $ROOTDIR
ADD packages/run.sh /usr/local/bin/
ADD packages/run_psql_scripts /usr/local/bin/
ADD packages/compile.sh $ROOTDIR/src/

ADD https://ftp.postgresql.org/pub/source/v${PG_VERSION}/postgresql-${PG_VERSION}.tar.bz2 $ROOTDIR/src/

ADD http://download.osgeo.org/geos/geos-${GEOS_VERSION}.tar.bz2 $ROOTDIR/src/

ADD http://download.osgeo.org/proj/proj-${PROJ4_VERSION}.tar.gz $ROOTDIR/src/
ADD http://download.osgeo.org/proj/proj-datumgrid-1.5.tar.gz $ROOTDIR/src/
ADD https://raw.githubusercontent.com/GeographicaGS/Spanish-Geodetics-Patches/master/proj4/proj${PROJ4_VERSION}-patch/src/pj_datums.c $ROOTDIR/src/
ADD https://raw.githubusercontent.com/GeographicaGS/Spanish-Geodetics-Patches/master/proj4/proj${PROJ4_VERSION}-patch/nad/PENR2009.gsb $ROOTDIR/src/
ADD https://raw.githubusercontent.com/GeographicaGS/Spanish-Geodetics-Patches/master/proj4/proj${PROJ4_VERSION}-patch/nad/epsg $ROOTDIR/src/

ADD http://download.osgeo.org/postgis/source/postgis-${POSTGIS_VERSION}.tar.gz $ROOTDIR/src/
ADD https://raw.githubusercontent.com/GeographicaGS/Spanish-Geodetics-Patches/master/postgis/postgis-${POSTGIS_VERSION}/spatial_ref_sys.sql $ROOTDIR/src/

ADD http://download.osgeo.org/gdal/2.0.2/gdal-${GDAL_VERSION}.tar.gz $ROOTDIR/src/
ADD https://raw.githubusercontent.com/GeographicaGS/Spanish-Geodetics-Patches/master/gdal/gdal-patch-${GDAL_VERSION}/data/gcs.csv $ROOTDIR/src/
ADD https://raw.githubusercontent.com/GeographicaGS/Spanish-Geodetics-Patches/master/gdal/gdal-patch-${GDAL_VERSION}/data/epsg.wkt $ROOTDIR/src/

ADD https://github.com/CGAL/cgal/archive/releases/CGAL-${CGAL_VERSION}.tar.gz $ROOTDIR/src/

ADD https://codeload.github.com/Oslandia/SFCGAL/tar.gz/v${SFCGAL_VERSION} $ROOTDIR/src/SFCGAL-${SFCGAL_VERSION}.tar.gz


# Compilation
RUN chmod 777 src/compile.sh
RUN src/compile.sh

# Final touches
EXPOSE 5432

# Volumes
VOLUME $POSTGRES_DATA_FOLDER

ENTRYPOINT ["/usr/local/bin/run.sh"]
