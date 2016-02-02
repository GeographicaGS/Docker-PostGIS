FROM ubuntu:latest

MAINTAINER Juan Pedro Perez "jp.alcantara@geographica.gs"

# Environment
ENV POSTGRES_PASSWD postgres
ENV ROOTDIR /usr/local/
ENV POSTGRES_DATA_FOLDER /data
ENV ENCODING UTF-8
ENV LOCALE es_ES.UTF-8
ENV COLLATE es_ES.UTF-8
ENV LC_MONETARY es_ES.UTF-8
ENV LC_NUMERIC es_ES.UTF-8
ENV LC_TIME es_ES.UTF-8
ENV PSQL_SCRIPTS /usr/local/Dummy_psql_command.sql;/usr/local/Dummy_psql_command.sql


# Load assets
WORKDIR $ROOTDIR/
ADD packages/Dummy_psql_command.sql $ROOTDIR
ADD https://ftp.postgresql.org/pub/source/v9.3.5/postgresql-9.3.5.tar.bz2 $ROOTDIR/src/
ADD http://download.osgeo.org/geos/geos-3.4.2.tar.bz2 $ROOTDIR/src/
ADD http://download.osgeo.org/proj/proj-4.9.1.tar.gz $ROOTDIR/src/
ADD packages/proj4-patch/src/pj_datums.c $ROOTDIR/src/
ADD http://download.osgeo.org/proj/proj-datumgrid-1.5.tar.gz $ROOTDIR/src/
ADD packages/proj4-patch/nad/epsg $ROOTDIR/src/
ADD packages/proj4-patch/nad/PENR2009.gsb $ROOTDIR/src/
ADD http://download.osgeo.org/postgis/source/postgis-2.1.7.tar.gz $ROOTDIR/src/
ADD packages/postgis-patch/spatial_ref_sys.sql $ROOTDIR/src/
ADD http://download.osgeo.org/gdal/1.11.2/gdal-1.11.2.tar.gz $ROOTDIR/src/
ADD packages/run.sh /usr/local/bin/
ADD packages/run_psql_scripts /usr/local/bin/
ADD packages/compile.sh $ROOTDIR/src/

# Compilation
RUN chmod 777 src/compile.sh
RUN src/compile.sh

# Final touches
EXPOSE 5432

# Volumes
VOLUME $POSTGRES_DATA_FOLDER

ENTRYPOINT ["/usr/local/bin/run.sh"]
