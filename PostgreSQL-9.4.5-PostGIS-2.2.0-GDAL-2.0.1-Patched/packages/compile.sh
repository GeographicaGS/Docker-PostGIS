#!/bin/bash

while [[ $# > 1 ]]
do
key="$1"
case $key in
  -e|--encoding)
  ENCODING="$2"
  shift # past argument
  ;;
  -l|--locale)
  LOCALE="$2"
  shift # past argument
  ;;
  --pg-version)
  PG_VERSION="$2"
  shift # past argument
  ;;
  --geos-version)
  GEOS_VERSION="$2"
  shift # past argument
  ;;
  --proj4-version)
  PROJ4_VERSION="$2"
  shift # past argument
  ;;

  --postgis-version)
  POSTGIS_VERSION="$2"
  shift # past argument
  ;;

  --gdal-version)
  GDAL_VERSION="$2"
  shift # past argument
  ;;

  *)
          # unknown option
  ;;
esac
shift # past argument or value
done

# Update and apt-get basic packages

apt-get update && apt-get install -y build-essential python python-dev libreadline6-dev zlib1g-dev libssl-dev libxml2-dev libxslt-dev locales libjson-c-dev

localedef -i $LOCALE -c -f $ENCODING -A /usr/share/locale/locale.alias ${LOCALE}.${ENCODING}

locale-gen ${LOCALE}.${ENCODING}

# Untar
cd src ; tar -xjvf postgresql-${PG_VERSION}.tar.bz2 ; cd ..

cd src ; tar -xjvf geos-${GEOS_VERSION}.tar.bz2 ; cd ..

cd src ; tar -xvf proj-${PROJ4_VERSION}.tar.gz ; cd ..

cd src ; mkdir -p proj-datumgrid ; cd ..

cd src ; tar -xvf proj-datumgrid-1.5.tar.gz -C proj-datumgrid ; cd ..

cd src ; tar -xvf postgis-${POSTGIS_VERSION}.tar.gz ; cd ..

cd src ; tar -xvf gdal-${GDAL_VERSION}.tar.gz ; cd ..


# Compilation of PostgreSQL
cd src/postgresql-${PG_VERSION} ; ./configure --prefix=/usr/local --with-pgport=5432 --with-python --with-openssl --with-libxml --with-libxslt --with-zlib ; cd ../..

cd src/postgresql-${PG_VERSION} ; make ; cd ../..

cd src/postgresql-${PG_VERSION} ; make install ; cd ../..

cd src/postgresql-${PG_VERSION}/contrib ; make all ; cd ../../..

cd src/postgresql-${PG_VERSION}/contrib ; make install ; cd ../../..

groupadd postgres

useradd -r postgres -g postgres

ldconfig


# Compilation of GEOS
cd src/geos-${GEOS_VERSION} ; ./configure ; cd ../..

cd src/geos-${GEOS_VERSION} ; make ; cd ../..

cd src/geos-${GEOS_VERSION} ; make install ; cd ../..

ldconfig

# Compilation of Proj 4
mv src/proj-datumgrid/* src/proj-${PROJ4_VERSION}/nad

mv src/pj_datums.c src/proj-${PROJ4_VERSION}/src

mv src/epsg src/proj-${PROJ4_VERSION}/nad/

mv src/PENR2009.gsb src/proj-${PROJ4_VERSION}/nad/

# chown -R 142957:5000 src/proj-${PROJ4_VERSION}

cd src/proj-${PROJ4_VERSION} ; ./configure ; cd ../..

cd src/proj-${PROJ4_VERSION} ; make ; cd ../..

cd src/proj-${PROJ4_VERSION} ; make install ; cd ../..

ldconfig


# Compilation of GDAL
cd src/gdal-${GDAL_VERSION}  ; ./configure ; cd ../..

cd src/gdal-${GDAL_VERSION}  ; make ; cd ../..

cd src/gdal-${GDAL_VERSION}  ; make install ; cd ../..

ldconfig

# Compilation of PostGIS
mv src/spatial_ref_sys.sql src/postgis-${POSTGIS_VERSION}/

cd src/postgis-${POSTGIS_VERSION} ; ./configure --with-jsondir=/usr/include/json-c ; cd ../..

cd src/postgis-${POSTGIS_VERSION} ; make ; cd ../..

cd src/postgis-${POSTGIS_VERSION} ; make install ; cd ../..

ldconfig

# Clean up
apt-get clean && rm -rf /var/lib/apt/lists/* && rm -Rf /usr/local/src && apt-get remove -y --purge build-essential gcc-4.7 && apt-get -y autoremove

chmod 755 /usr/local/bin/run

chown postgres:postgres /usr/local/bin/run
