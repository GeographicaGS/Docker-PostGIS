#!/bin/bash
# Compilation of PostgreSQL, GEOS, Proj4, and PostGIS
set -exu

exec_dir=$PWD

current_os=$(set +x; . /etc/os-release; echo ${ID})
current_os_version=$(set +x; . /etc/os-release; echo ${VERSION_ID})

if [ "$current_os" = "ubuntu" ]; then
    BUILD_DEPENDENCIES="$( set +x; echo \
        `# Required !` \
        build-essential \
        python \
        python-dev \
        curl \
        ca-certificates \
        gnupg \
        locales \
        pkg-config \
        libreadline-dev \
        zlib1g-dev \
        libssl-dev \
        libxml2-dev \
        libxslt1-dev \
        libjson-c-dev \
        libprotobuf-c-dev \
        libprotoc-dev \
        protobuf-compiler \
        protobuf-c-compiler \
        libsqlite3-dev\
        sqlite3 \
        llvm-dev \
        clang \
      )"
    RUN_DEPENDENCIES="$( set +x; echo \
        `# Required !` \
        python \
        locales \
        libreadline7 \
        zlib1g \
        libssl1.0.0 \
        libxml2 \
        libxslt1.1 \
        libjson-c3 \
        libprotobuf-c1 \
        libprotoc10 \
        sqlite3 \
        llvm \
      )"
elif [ "$current_os" = "debian" ]; then
    echo "here!"
else
    echo "Operating System `$curren_os` not supported"
    exit 1
fi

# Update and apt-get basic packages
apt-get update \
    && apt-get install \
        -y \
        --no-install-recommends \
       $BUILD_DEPENDENCIES

# Download & untar sources
curl --progress-bar https://ftp.postgresql.org/pub/source/v${PG_VERSION}/postgresql-${PG_VERSION}.tar.bz2 | tar xj -C /usr/local/src/
curl --progress-bar http://download.osgeo.org/geos/geos-${GEOS_VERSION}.tar.bz2 | tar xj -C /usr/local/src/
curl --progress-bar http://download.osgeo.org/proj/proj-${PROJ4_VERSION}.tar.gz | tar xz -C /usr/local/src/
curl --progress-bar http://download.osgeo.org/postgis/source/postgis-${POSTGIS_VERSION}.tar.gz | tar xz -C /usr/local/src/


# Grab gosu
for server in ha.pool.sks-keyservers.net \
              hkp://p80.pool.sks-keyservers.net:80 \
              keyserver.ubuntu.com \
              hkp://keyserver.ubuntu.com:80 \
              pgp.mit.edu; do
    gpg --keyserver "$server" --recv-keys B42F6819007F00F88E364FD4036A9C25BF357DD4 && break || echo "Trying new server..."
done

curl -o /usr/local/bin/gosu \
     -SL "https://github.com/tianon/gosu/releases/download/${GOSU_VERSION}/gosu-$(dpkg --print-architecture)" > \
     /dev/null 2>&1 \
    && curl -o /usr/local/bin/gosu.asc \
        -SL "https://github.com/tianon/gosu/releases/download/${GOSU_VERSION}/gosu-$(dpkg --print-architecture).asc" > \
        /dev/null 2>&1 \
    && gpg --verify /usr/local/bin/gosu.asc > /dev/null 2>&1 \
    && rm /usr/local/bin/gosu.asc > /dev/null 2>&1 \
    && chmod +x /usr/local/bin/gosu > /dev/null 2>&1

# Compilation of PostgreSQL
cd src/postgresql-${PG_VERSION}
    ./configure --prefix=/usr/local --with-pgport=5432 --with-python --with-openssl --with-libxml --with-libxslt --with-zlib --with-llvm
    make -j "$(nproc)"
    make install
    make all
    make install
cd ../..
ldconfig

# Compilation of GEOS
cd src/geos-${GEOS_VERSION}
    ./configure
    make -j "$(nproc)"
    make install
cd ../..
ldconfig

# Compilation of Proj4
cd src/proj-${PROJ4_VERSION}
    ./configure
    make -j "$(nproc)"
    make install
cd ../..
ldconfig

# Compilation of PostGIS
cd src/postgis-${POSTGIS_VERSION}
    ./configure --with-topology --without-raster --with-jsondir=/usr
    make -j "$(nproc)"
    make install
cd ../..
ldconfig

# Clean up
rm -rf /usr/local/src \
    /usr/local/share/doc* \
    /usr/local/share/man
apt-get remove \
    -y \
    --purge \
    --auto-remove \
    $BUILD_DEPENDENCIES

## Clean "a" files (Not required after compilation)
find /usr/local/lib/ -name '*.a' -delete

# Install run dependencies
apt-get install \
    -y \
    --no-install-recommends \
    $RUN_DEPENDENCIES

rm -rf /var/lib/apt/lists/*
