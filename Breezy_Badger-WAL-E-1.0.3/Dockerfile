FROM geographica/postgis:breezy_badger

MAINTAINER Jose M. Camacho "jcamacho@geographica.gs"

# Install WAL-E
RUN DEBIAN_FRONTEND=noninteractive apt-get -qq update
RUN DEBIAN_FRONTEND=noninteractive apt-get -qqy install --no-install-recommends lzop pv python3-dev python3-pip

# Remove this before merge with master
RUN DEBIAN_FRONTEND=noninteractive apt-get -qqy install --no-install-recommends vim

RUN DEBIAN_FRONTEND=noninteractive apt-get -qqy autoremove
RUN DEBIAN_FRONTEND=noninteractive apt-get -qqy autoclean
RUN rm -rf /var/lib/apt/lists/*
RUN pip3 install -q --no-cache-dir -U pip wheel setuptools
RUN pip install -q --no-cache-dir wal-e[aws]==1.0.3

# Environment
ARG WAL_TIMEOUT=300
ENV PG_WAL_CONF "max_connections=100#listen_addresses='*'#shared_buffers=128MB#dynamic_shared_memory_type=posix#log_timezone='UTC'#datestyle='iso, mdy'#timezone='UTC'#log_statement='all'#log_directory='pg_log'#log_filename='postgresql-%Y-%m-%d_%H%M%S.log'#logging_collector=on#client_min_messages=notice#log_min_messages=notice#log_line_prefix='%a %u %d %r %h %m %i %e'#log_destination='stderr,csvlog'#log_rotation_size=500MB#log_error_verbosity=default#wal_level='archive'#archive_mode=on#archive_timeout=${WAL_TIMEOUT}#archive_command='/usr/local/bin/wal-e wal-push %p'"
ENV PG_WAL_RECOVERY_CONF "restore_command='/usr/local/bin/wal-e wal-fetch %f %p'"
ENV PG_WAL null
ENV PG_WAL_RECOVERY null

# Load assets
RUN rm -f /usr/local/bin/run.sh /usr/local/bin/postgresql_conf
ADD packages/run.sh /usr/local/bin/
ADD packages/postgresql_conf /usr/local/bin
