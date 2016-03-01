FROM ubuntu:latest

MAINTAINER Juan Pedro Perez "jp.alcantara@geographica.gs"

# # Arguments
# ARG locale=en_US

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


# # All this should go to compile.sh latter

# RUN apt-get update && apt-get install -y build-essential python python-dev libreadline6-dev zlib1g-dev libssl-dev libxml2-dev libxslt-dev curl cmake libgmp-dev libmpfr-dev libboost-dev libboost-thread-dev libboost-system-dev


# # Grab gosu
# RUN gpg --keyserver pool.sks-keyservers.net --recv-keys B42F6819007F00F88E364FD4036A9C25BF357DD4

# RUN curl -o /usr/local/bin/gosu -SL "https://github.com/tianon/gosu/releases/download/1.2/gosu-$(dpkg --print-architecture)" > /dev/null 2>&1 && curl -o /usr/local/bin/gosu.asc -SL "https://github.com/tianon/gosu/releases/download/1.2/gosu-$(dpkg --print-architecture).asc" > /dev/null 2>&1 && gpg --verify /usr/local/bin/gosu.asc  > /dev/null 2>&1 && rm /usr/local/bin/gosu.asc  > /dev/null 2>&1 && chmod +x /usr/local/bin/gosu  > /dev/null 2>&1


# # Untar
# RUN cd src ; tar -xjvf postgresql-9.5.0.tar.bz2 ; cd ..
# RUN cd src ; tar -xjvf geos-3.5.0.tar.bz2 ; cd ..
# RUN cd src ; tar -xvf proj-4.9.2.tar.gz ; cd ..
# RUN cd src ; mkdir -p proj-datumgrid ; cd ..
# RUN cd src ; tar -xvf proj-datumgrid-1.5.tar.gz -C proj-datumgrid ; cd ..
# RUN cd src ; tar -xvf postgis-2.2.1.tar.gz ; cd ..
# RUN cd src ; tar -xvf gdal-2.0.2.tar.gz ; cd ..
# RUN cd src ; tar -xvf CGAL-4.6.3.tar.gz ; cd ..
# RUN cd src ; tar -xzvf SFCGAL-1.3.0.tar.gz ; cd ..

# # Compilation of PostgreSQL
# RUN cd src/postgresql-9.5.0 ; ./configure --prefix=/usr/local --with-pgport=5432 --with-python --with-openssl --with-libxml --with-libxslt --with-zlib ; cd ../..

# RUN cd src/postgresql-9.5.0 ; make ; cd ../..

# RUN cd src/postgresql-9.5.0 ; make install ; cd ../..

# RUN cd src/postgresql-9.5.0/contrib ; make all ; cd ../../..

# RUN cd src/postgresql-9.5.0/contrib ; make install ; cd ../../..

# RUN groupadd postgres

# RUN useradd -r postgres -g postgres

# RUN ldconfig









# # Compilation of GEOS
# RUN cd src/geos-3.5.0 ; ./configure ; cd ../..

# RUN cd src/geos-3.5.0 ; make ; cd ../..

# RUN cd src/geos-3.5.0 ; make install ; cd ../..

# RUN ldconfig




# # Compilation of Proj 4
# RUN mv src/proj-datumgrid/* src/proj-4.9.2/nad

# RUN mv src/pj_datums.c src/proj-4.9.2/src

# RUN mv src/epsg src/proj-4.9.2/nad/

# RUN mv src/PENR2009.gsb src/proj-4.9.2/nad/

# RUN cd src/proj-4.9.2 ; ./configure ; cd ../..

# RUN cd src/proj-4.9.2 ; make ; cd ../..

# RUN cd src/proj-4.9.2 ; make install ; cd ../..

# RUN ldconfig


# # Compilation of GDAL
# RUN cd src/gdal-2.0.2 ; ./configure ; cd ../..

# RUN cd src/gdal-2.0.2 ; make ; cd ../..

# RUN cd src/gdal-2.0.2 ; make install ; cd ../..

# RUN mv src/data/* /usr/local/share/gdal

# RUN ldconfig




# # Compilation of CGAL
# RUN cd src/cgal-releases-CGAL-4.6.3 ; cmake -DWITH_CGAL=ON -DWITH_CGAL_Core=ON -DWITH_CGAL_ImageIO=OFF -DWITH_CGAL_Qt3=OFF -DWITH_CGAL_Qt5=OFF -DWITH_tests=OFF -DWITH_examples=OFF -DWITH_demos=OFF -DCMAKE_BUILD_TYPE=Release . ; cd ../..

# RUN cd src/cgal-releases-CGAL-4.6.3 ; make ; cd ../..

# RUN cd src/cgal-releases-CGAL-4.6.3 ; make install ; cd ../..




# # Compilation of SFCGAL

# RUN cd src/SFCGAL-1.3.0 ; cmake . ; cd ../..

# RUN cd src/SFCGAL-1.3.0 ; make ; cd ../..

# RUN cd src/SFCGAL-1.3.0 ; make install ; cd ../..



# # Compilation of PostGIS
# # RUN mv src/spatial_ref_sys.sql src/postgis-2.2.1/

# # RUN cd src/postgis-2.2.1 ; ./configure --with-topology ; cd ../..

# # RUN cd src/postgis-2.2.1 ; make ; cd ../..

# # RUN cd src/postgis-2.2.1 ; make install ; cd ../..

# # RUN locale-gen en_US.UTF-8

# # RUN locale-gen es_ES.UTF-8

# # RUN ldconfig





# # RUN rm -Rf /usr/local/src

# RUN chmod 755 /usr/local/bin/run.sh

# RUN chown postgres:postgres /usr/local/bin/run.sh



# # HERE ENDS THE DEBUG SECTION THAT HAS TO BE MOVED TO COMPILE




# # AND THIS IS PART OF RUN.SH

# # Create data store
# RUN mkdir -p ${POSTGRES_DATA_FOLDER}
# RUN chown postgres:postgres ${POSTGRES_DATA_FOLDER}
# RUN chmod 700 ${POSTGRES_DATA_FOLDER}

# RUN locale-gen ${LOCALE}





# # HERE ENDS THE DEBUG SECTION THAT HAS TO BE MOVED TO RUN.SH



# # Compilation
# # RUN chmod 777 src/compile.sh
# # RUN src/compile.sh

# # Final touches
# EXPOSE 5432

# # Volumes
# VOLUME $POSTGRES_DATA_FOLDER

# ENTRYPOINT ["/usr/local/bin/run.sh"]
