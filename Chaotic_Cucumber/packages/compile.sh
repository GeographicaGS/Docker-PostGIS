# Compilation of CGAL and PGRouting

# Update and apt-get basic packages
apt-get update \
    && apt-get install -y \
	       cmake \
	       libboost-dev \
	       libboost-thread-dev \
	       libgmp3-dev \
	       libmpfr-dev


# Untar
cd src ; tar -xvf CGAL-${CGAL_VERSION}.tar.gz ; cd ..
cd src ; tar -xvf v${PGROUTING_VERSION}.tar.gz ; cd ..


# Compilation of CGAL
cd src/cgal-releases-CGAL-${CGAL_VERSION} ; \
    cmake . ; \
    make ; \
    make install ; \
    ldconfig ; \
    cd ../..


# Compilation of PGRouting
cd src/pgrouting-${PGROUTING_VERSION} ; \
    cmake -L ; \
    make ; \
    make install ; \
    ldconfig ; \
    cd ../..


# Clean up
rm -Rf /usr/local/src
