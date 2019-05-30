FROM ubuntu:18.04

WORKDIR /usr/local

# Environment
ENV PG_VERSION 12beta1
ENV GEOS_VERSION 3.7.2
ENV PROJ4_VERSION 6.1.0
ENV GDAL_VERSION 2.4.1
ENV POSTGIS_VERSION 3.0.0alpha1
ENV GOSU_VERSION 1.9
ENV ENCODING UTF-8
ENV LOCALE en_US
ENV TERM xterm
ENV POSTGRES_PASSWD postgres
ENV PG_HBA "local all all trust#host all all 127.0.0.1/32 trust#host all all 0.0.0.0/0 md5#host all all ::1/128 trust"
ENV PG_CONF "max_connections=100#listen_addresses='*'#shared_buffers=128MB#dynamic_shared_memory_type=posix#log_timezone='UTC'#datestyle='iso, mdy'#timezone='UTC'#log_statement='all'#log_directory='pg_log'#log_filename='postgresql-%Y-%m-%d_%H%M%S.log'#logging_collector=on#client_min_messages=notice#log_min_messages=notice#log_line_prefix='%a %u %d %r %h %m %i %e'#log_destination='stderr'#log_rotation_size=500MB#log_error_verbosity=default"
ENV PGDATA /data

# Creation of postgres user and group
RUN \
    set -ex; \
    useradd --shell /bin/bash --home /data/ postgres \
    && mkdir -p "$PGDATA" \
    && chown -R postgres:postgres "$PGDATA" \
    && chmod 777 "$PGDATA"

# Load assets
ADD packages/pg_hba_conf /usr/local/bin
ADD packages/postgresql_conf /usr/local/bin
ADD packages/psqlrc /root/.psqlrc
ADD packages/compile.sh /usr/local/src/

# Compilation
RUN src/compile.sh

VOLUME /data

RUN chmod +x /usr/local/bin/pg_hba_conf
RUN chmod +x /usr/local/bin/postgresql_conf

STOPSIGNAL SIGINT
COPY packages/run.sh /usr/local/bin/
ENTRYPOINT ["/usr/local/bin/run.sh"]

EXPOSE 5432
CMD ["run_default"]
