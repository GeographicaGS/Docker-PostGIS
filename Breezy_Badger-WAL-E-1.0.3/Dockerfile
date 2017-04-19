FROM geographica/postgis:breezy_badger

MAINTAINER Jose M. Camacho "jcamacho@geographica.gs"

# Install WAL-E
RUN DEBIAN_FRONTEND=noninteractive apt-get -qq update
RUN DEBIAN_FRONTEND=noninteractive apt-get -qqy install --no-install-recommends lzop pv python3-dev python3-pip

RUN DEBIAN_FRONTEND=noninteractive apt-get -qqy autoremove
RUN DEBIAN_FRONTEND=noninteractive apt-get -qqy autoclean
RUN rm -rf /var/lib/apt/lists/*
RUN pip3 install -q --no-cache-dir -U pip wheel setuptools
RUN pip install -q --no-cache-dir wal-e[aws]==1.0.3

# Environment
ARG WAL_TIMEOUT=300
ENV PG_WAL_CONF "wal_level='archive'#archive_mode=on#archive_timeout=${WAL_TIMEOUT}#archive_command='/usr/local/bin/wal-e wal-push %p'"
ENV PG_WAL_RECOVERY_CONF "restore_command='/usr/local/bin/wal-e wal-fetch %f %p'"
ENV PG_WAL null
ENV PG_WAL_RECOVERY null

# Load assets
ADD packages/run.sh /usr/local/bin/
ADD packages/postgresql_conf /usr/local/bin
