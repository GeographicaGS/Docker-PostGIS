# Compilation of PostgreSQL 9.3.5, GEOS 3.4.2, Proj 4.9.1, GDAL 1.11.2, and PostGIS 2.1.7

# Update and apt-get basic packages
apt-get update && apt-get install -y build-essential gcc-4.7 python python-dev libreadline6-dev zlib1g-dev libssl-dev libxml2-dev libxslt-dev curl

# Grab gosu
gpg --keyserver pool.sks-keyservers.net --recv-keys B42F6819007F00F88E364FD4036A9C25BF357DD4
curl -o /usr/local/bin/gosu -SL "https://github.com/tianon/gosu/releases/download/1.2/gosu-$(dpkg --print-architecture)" > /dev/null 2>&1 && curl -o /usr/local/bin/gosu.asc -SL "https://github.com/tianon/gosu/releases/download/1.2/gosu-$(dpkg --print-architecture).asc" > /dev/null 2>&1 && gpg --verify /usr/local/bin/gosu.asc  > /dev/null 2>&1 && rm /usr/local/bin/gosu.asc  > /dev/null 2>&1 && chmod +x /usr/local/bin/gosu  > /dev/null 2>&1

# Untar
cd src ; tar -xjvf postgresql-9.3.5.tar.bz2 ; cd ..

cd src ; tar -xjvf geos-3.4.2.tar.bz2 ; cd ..

cd src ; tar -xvf proj-4.9.1.tar.gz ; cd ..

cd src ; mkdir -p proj-datumgrid ; cd ..

cd src ; tar -xvf proj-datumgrid-1.5.tar.gz -C proj-datumgrid ; cd ..

cd src ; tar -xvf postgis-2.1.7.tar.gz ; cd ..

cd src ; tar -xvf gdal-1.11.2.tar.gz ; cd ..


# Compilation of PostgreSQL
cd src/postgresql-9.3.5 ; ./configure --prefix=/usr/local --with-pgport=5432 --with-python --with-openssl --with-libxml --with-libxslt --with-zlib ; cd ../..

cd src/postgresql-9.3.5 ; make ; cd ../..

cd src/postgresql-9.3.5 ; make install ; cd ../..

cd src/postgresql-9.3.5/contrib ; make all ; cd ../../..

cd src/postgresql-9.3.5/contrib ; make install ; cd ../../..

groupadd postgres

useradd -r postgres -g postgres

ldconfig

# Compilation of GEOS
cd src/geos-3.4.2 ; ./configure ; cd ../..

cd src/geos-3.4.2 ; make ; cd ../..

cd src/geos-3.4.2 ; make install ; cd ../..

ldconfig

# Compilation of Proj 4
mv src/proj-datumgrid/* src/proj-4.9.1/nad

mv src/pj_datums.c src/proj-4.9.1/src

mv src/epsg src/proj-4.9.1/nad/

mv src/PENR2009.gsb src/proj-4.9.1/nad/

cd src/proj-4.9.1 ; ./configure ; cd ../..

cd src/proj-4.9.1 ; make ; cd ../..

cd src/proj-4.9.1 ; make install ; cd ../..

ldconfig


# Compilation of GDAL
cd src/gdal-1.11.2 ; ./configure ; cd ../..

cd src/gdal-1.11.2 ; make ; cd ../..

cd src/gdal-1.11.2 ; make install ; cd ../..

ldconfig


# Compilation of PostGIS
mv src/spatial_ref_sys.sql src/postgis-2.1.7/

cd src/postgis-2.1.7 ; ./configure --with-topology ; cd ../..

cd src/postgis-2.1.7 ; make ; cd ../..

cd src/postgis-2.1.7 ; make install ; cd ../..

locale-gen en_US.UTF-8

locale-gen es_ES.UTF-8

ldconfig


# Clean up
rm -Rf /usr/local/src

chmod 755 /usr/local/bin/run.sh

chown postgres:postgres /usr/local/bin/run.sh
