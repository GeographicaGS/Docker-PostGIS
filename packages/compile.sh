# Compilation of PostgreSQL 9.3.5, GEOS 3.4.2, Proj 4.9.1, GDAL 1.11.2, and PostGIS 2.1.7

# Untar
cd src ; tar -xjvf postgresql-9.3.5.tar.bz2 ; cd ..

cd src ; tar -xjvf geos-3.4.2.tar.bz2 ; cd ..

cd src ; tar -xvf proj-4.9.1.tar.gz ; cd ..

mkdir src/proj-datumgrid

cd src ; tar -xvf proj-datumgrid-1.5.tar.gz -C proj-datumgrid ; cd ..

cd src ; tar -xvf postgis-2.1.7.tar.gz ; cd ..

cd src ; tar -xvf gdal-1.11.2.tar.gz ; cd ..

# Update and apt-get basic packages
apt-get update && apt-get install -y build-essential gcc-4.7 python python-dev libreadline6-dev zlib1g-dev libssl-dev libxml2-dev libxslt-dev

# Compilation of PostgreSQL
cd src/postgresql-9.3.5 ; ./configure --prefix=/usr/local --with-pgport=5432 --with-python --with-openssl --with-libxml --with-libxslt --with-zlib ; cd ../..

cd src/postgresql-9.3.5 ; make ; cd ../..

cd src/postgresql-9.3.5 ; make install ; cd ../..

cd src/postgresql-9.3.5/contrib ; make all ; cd ../../..

cd src/postgresql-9.3.5/contrib ; make install ; cd ../../..

groupadd postgres

useradd -r postgres -g postgres

echo "postgres:${POSTGRES_PASSWD}" | chpasswd -e

# Compilation of GEOS
cd src/geos-3.4.2 ; ./configure ; cd ../..

cd src/geos-3.4.2 ; make ; cd ../..

cd src/geos-3.4.2 ; make install ; cd ../..

# Compilation of Proj 4
mv src/proj-datumgrid/* src/proj-4.9.1/nad

mv src/pj_datums.c src/proj-4.9.1/src

mv src/epsg src/proj-4.9.1/nad/

mv src/PENR2009.gsb src/proj-4.9.1/nad/

chown -R 142957:5000 src/proj-4.9.1

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

cd src/postgis-2.1.7 ; ./configure ; cd ../..

cd src/postgis-2.1.7 ; make ; cd ../..

cd src/postgis-2.1.7 ; make install ; cd ../..

locale-gen en_US.UTF-8

locale-gen es_ES.UTF-8

# Clean up
rm -Rf src

# Create data store
mkdir -p ${POSTGRES_DATA_FOLDER}

chown postgres:postgres ${POSTGRES_DATA_FOLDER}

chmod 700 ${POSTGRES_DATA_FOLDER}

su postgres -c "initdb --encoding=${ENCODING} --locale=${LOCALE} --lc-collate=${COLLATE} --lc-monetary=${LC_MONETARY} --lc-numeric=${LC_NUMERIC} --lc-time=${LC_TIME} -D ${POSTGRES_DATA_FOLDER}"
