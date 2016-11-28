FROM geographica/postgis:breezy_badger

MAINTAINER Juan Pedro Perez "jp.alcantara@geographica.gs"


# Environment
ENV PGROUTING_VERSION 2.3.1
ENV CGAL_VERSION 4.9


# Sources
ADD https://github.com/pgRouting/pgrouting/archive/v${PGROUTING_VERSION}.tar.gz $ROOTDIR/src/
ADD https://github.com/CGAL/cgal/archive/releases/CGAL-${CGAL_VERSION}.tar.gz $ROOTDIR/src/
ADD packages/compile.sh $ROOTDIR/src/


# Compilation
RUN chmod 777 src/compile.sh
RUN src/compile.sh
