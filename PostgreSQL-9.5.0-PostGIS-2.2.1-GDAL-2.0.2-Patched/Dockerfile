FROM ubuntu:latest

MAINTAINER Juan Pedro Perez "jp.alcantara@geographica.gs"

# Environment
ENV POSTGRES_PASSWD postgres
ENV ROOTDIR /usr/local/
ENV POSTGRES_DATA_FOLDER /data
ENV ENCODING UTF-8
ENV LOCALE es_ES.UTF-8
ENV PSQL_SCRIPTS /usr/local/Dummy_psql_command.sql;/usr/local/Dummy_psql_command.sql


# Load assets
WORKDIR $ROOTDIR/
ADD packages/Dummy_psql_command.sql $ROOTDIR
ADD https://ftp.postgresql.org/pub/source/v9.5.0/postgresql-9.5.0.tar.bz2 $ROOTDIR/src/
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


# All this should go to compile.sh latter

RUN apt-get update && apt-get install -y build-essential python python-dev libreadline6-dev zlib1g-dev libssl-dev libxml2-dev libxslt-dev curl


# Grab gosu
RUN gpg --keyserver pool.sks-keyservers.net --recv-keys B42F6819007F00F88E364FD4036A9C25BF357DD4

RUN curl -o /usr/local/bin/gosu -SL "https://github.com/tianon/gosu/releases/download/1.2/gosu-$(dpkg --print-architecture)" > /dev/null 2>&1 && curl -o /usr/local/bin/gosu.asc -SL "https://github.com/tianon/gosu/releases/download/1.2/gosu-$(dpkg --print-architecture).asc" > /dev/null 2>&1 && gpg --verify /usr/local/bin/gosu.asc  > /dev/null 2>&1 && rm /usr/local/bin/gosu.asc  > /dev/null 2>&1 && chmod +x /usr/local/bin/gosu  > /dev/null 2>&1


# Untar
RUN cd src ; tar -xjvf postgresql-9.5.0.tar.bz2 ; cd ..
# RUN cd src ; tar -xjvf geos-3.4.2.tar.bz2 ; cd ..
# RUN cd src ; tar -xvf proj-4.9.1.tar.gz ; cd ..
# RUN cd src ; mkdir -p proj-datumgrid ; cd ..
# RUN cd src ; tar -xvf proj-datumgrid-1.5.tar.gz -C proj-datumgrid ; cd ..
# RUN cd src ; tar -xvf postgis-2.1.7.tar.gz ; cd ..
# RUN cd src ; tar -xvf gdal-1.11.2.tar.gz ; cd ..

# Compilation of PostgreSQL
RUN cd src/postgresql-9.5.0 ; ./configure --prefix=/usr/local --with-pgport=5432 --with-python --with-openssl --with-libxml --with-libxslt --with-zlib ; cd ../..

RUN cd src/postgresql-9.5.0 ; make ; cd ../..

RUN cd src/postgresql-9.5.0 ; make install ; cd ../..

RUN cd src/postgresql-9.5.0/contrib ; make all ; cd ../../..

RUN cd src/postgresql-9.5.0/contrib ; make install ; cd ../../..

RUN groupadd postgres

RUN useradd -r postgres -g postgres

RUN ldconfig








RUN rm -Rf /usr/local/src

RUN chmod 755 /usr/local/bin/run.sh

RUN chown postgres:postgres /usr/local/bin/run.sh



# HERE ENDS THE DEBUG SECTION THAT HAS TO BE MOVED TO COMPILE




# AND THIS IS PART OF RUN.SH

# Create data store
RUN mkdir -p ${POSTGRES_DATA_FOLDER}
RUN chown postgres:postgres ${POSTGRES_DATA_FOLDER}
RUN chmod 700 ${POSTGRES_DATA_FOLDER}

RUN locale-gen ${LOCALE}





# HERE ENDS THE DEBUG SECTION THAT HAS TO BE MOVED TO RUN.SH



# Compilation
# RUN chmod 777 src/compile.sh
# RUN src/compile.sh

# Final touches
EXPOSE 5432

# Volumes
VOLUME $POSTGRES_DATA_FOLDER

# ENTRYPOINT ["/usr/local/bin/run.sh"]
