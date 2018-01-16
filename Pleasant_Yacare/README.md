# PostgreSQL 10.1, PostGIS 2.4.3, GEOS 3.6.2, GDAL 2.2.3

# Contents
- [How to use](#how-to-use)
- [Versions](#versions)
- [Scripts](#scripts)
- [Executing Arbitrary Commands](#executing-arbitrary-commands)
- [Data Persistence](#data-persistence)
- [Passwords](#passwords)
- [Configuring the Data Store](#configuring-the-data-store)
- [Killing the Container](#killing-the-container)

## How to use

### Using Docker compose
docker-compose.yml:
```yml
version: "3"
services:
  postgis:
    image: geographica/postgis:pleasant_yacare
    ports:
      - "5432:5432"
    volumes:
      - db-data:/data
    environment:
      - POSTGRES_PASSWD=postgres
volumes:
  db-data:
```
Run:
```bash
docker-compose up
```

### Without compose
```
docker run --name postgis -p 5432:5432 geographica/postgis:pleasant_yacare
```

### Environment variables
This will create a container with a default volume, __/data__, for storing the data store. The default encoding will be __UTF-8__, and the locale __en_US__. No additional modification or action is taken.

Containers can be configured by means of setting environmental variables:

- __POSTGRES_PASSWD:__ set the password for user postgres. See [Passwords](#Passwords) for more details. Defaults to _postgres_;

- __ENCODING:__ encoding to create the data store and the default database, if applicable. Defaults to _UTF-8_;

- __LOCALE:__ locale for the data store and the default database, if any. Defaults to _en_US_;

- __PG_HBA:__ configuration of _pg_hba.con_ access file. See [Configuring the Data Store](#Configuring the Data Store) for details;

- __PG_CONF:__ configuration of _postgresql.conf_ See [Configuring the Data Store](#Configuring the Data Store) for details.

## Versions

This Dockerfile compiles the following software:

- __PostgreSQL 10.1;__

- __GEOS 3.6.2;__

- __Proj 4.9.3:__ patched with the spanish national grid for conversion between ED50 to ETRS89;

- __GDAL 2.2.3:__ also patched;

- __PostGIS 2.4.3:__ patched as well.


## Scripts

There is a script in this repo to help working with this image. __psql-docker__ opens a psql console on a standalone container to connect to other databases. To check how it works:

```Shell
psql-docker -h
```

## Executing Arbitrary Commands

The image can run arbitrary commands. This is useful for example for creating a temporary container for just dump a database, run a psql session with the one inside this image, or executing scripts into another container.

Some examples:

```Shell
# Interactive pg_dump, will ask for password

docker run --rm -ti -v /whatever/:/d --link the_container_running_the_database:pg \
geographica/postgis:pleasant_yacare \
pg_dump -b -E UTF8 -f /d/dump -F c -v -Z 9 -h pg -p 5432 -U postgres project

# Full automatic pg_dump, with password as ENV variable

docker run --rm -v /home/malkab/Desktop/:/d --link test_07:pg \
geographica/postgis:pleasant_yacare \
PGPASSWORD="new_password_here" pg_dump -b -E UTF8 -f /d/dump33 -F c \
-v -Z 9 -h pg -p 5432 -U postgres postgres

# Interactive psql

docker run --rm -ti -v /home/malkab/Desktop/:/d --link test_07:pg \ geographica/postgis:pleasant_yacare \ PGPASSWORD="new_password_here" psql -h pg -p 5432 -U postgres postgres
```

## Data Persistence

Datastore data can be persisted in a data volume or host mounted folder and be used later by another container. The container checks if __/data/__ is empty or not. If not, considers the datastore to be not created and creates an empty one.


## Passwords

Passwords sent to the container with environment variable __POSTGRES_PASSWD__ can be passed either on plain text or already encrypted á la PostgreSQL. To pass it on plain text means that anybody with access to the __docker inspect__ command on the server will be able to read passwords. Encrypting them previously means that __docker inspect__ will show the encrypted password, adding an additional layer of secrecy.

PostgreSQL passwords are encrypted using the MD5 checksum algorithm on the following literal:

```text
md5 + md5hash(real password + username)
```

For example, in the case of user _myself_ and password _secret_, the encrypted password will be the MD5 sum of _secretmyself_ prefixed with _md5_, in this case, _md5a296d28d6121e7307ac8e72635ae206b_.

To provide encrypted password to containers, use the following command:

```Shell
export USER="projectuser" && \
export USERPASSWD="md5"$(printf '%s' "userpass" ${USER} | md5sum | cut -d ' ' -f 1) && \
export PGPASSWD="md5"$(printf '%s' "password_here" "postgres" | md5sum | cut -d ' ' -f 1) && \
docker run -d -P --name ageworkshoptestpg -e "POSTGRES_PASSWD=${PGPASSWD}" \
-e "CREATE_USER=${USER}" -e "CREATE_USER_PASSWD=${USERPASSWD}" \
geographica/postgis:pleasant_yacare
```

Ugly, but effective. Keep in mind, however, that if you use provisioning methods like bash scripts or _Docker Compose_ others will still be able to read passwords from these sources, so keep them safe.


## Configuring the Data Store

The image allows for configuration of _pg_hba.conf_ and _postgresql.conf_ data store files at creation time and later. This is advanced stuff, refer to the PostgreSQL documentation for details.

_pg_hba.conf_ configuration is handled by a script called __pg_hba_conf__. _pg_hba_conf_ has three modes of operation:

```Shell
[1] pg_hba_conf l

[2] pg_hba_conf a "line 1#line 2#...#line n"

[3] pg_hba_conf d "line 1#line 2#...#line n"
```

which means:

- __[1]__ prints current contents of _pg_hba.conf_;

- __[2]__ adds lines to _pg_hba.conf_;

- __[3]__ deletes lines from _pg_hba.conf_.

This commands can be issued by standard Docker's __exec__:

```Shell
docker exec -ti whatevercontainer pg_hba_conf a \
"host all all 23.123.22.1/32 trust#host all all 93.32.12.3/32 md5"
```

but at startup it is controlled by an environment variable, __PG_HBA__, which defaults to:

```txt
ENV PG_HBA "local all all trust#host all all 127.0.0.1/32 trust#host all all 0.0.0.0/0 md5#host all all ::1/128 trust"
```

This defaults should be submitted for basic operation. For universal access, for example for testing, add:

```txt
local all all trust#host all all 0.0.0.0/0 trust#host all all 127.0.0.1/32 trust#host all all ::1/128 trust
```

Modify this variable to configure at creation time. Keep in mind, however, that any value provided to this variable will supersede the default. Don't forget to include basic access permissions if you modify this variable, or the server will be hardly reachable. For testing purposes, direct commands can be issued via __exec__.

Configuration of __postgresql.conf__ follows an identical procedure. Command is __postgresql_conf__ and has the same syntax as __pg_hba_conf__. The environmental variable is __PG_CONF__, which defaults to the following configuration:

```txt
max_connections=100#listen_addresses='*'#shared_buffers=128MB#dynamic_shared_memory_type=posix#log_timezone='UTC'#datestyle='iso, mdy'#timezone='UTC'#lc_messages='en_US.UTF-8'#lc_monetary='en_US.UTF-8'#lc_numeric='en_US.UTF-8'#lc_time='en_US.UTF-8'#log_statement='all'#log_directory='pg_log'#log_filename='postgresql-%Y-%m-%d_%H%M%S.log'#logging_collector=on#client_min_messages=notice#log_min_messages=notice#log_line_prefix='%a %u %d %r %h %m %i %e'#log_destination='stderr,csvlog'#log_rotation_size=500MB
```

At creation time, language, encoding, and locale info is added based on env variables __LOCALE__ and __ENCODING__.

Logs are stored at __$POSTGRES_DATA_FOLDER/pg_log__.


<a name="Killing the Container"></a>

## Killing the Container


This container will handle signals send to it with _docker kill_ properly, so the database is shut down tidily. Thus:

- __SIGTERM__ signals for a smart shutdown, waiting for all connections and transactions to be finished. The server won't allow for new connections, thou:

```Shell
pg_ctl -D . stop -m smart

docker kill -s SIGTERM containername
```

- __SIGINT__ signals for fast shutdown. The server will abort current transactions and disconnect users, but will exit nicely otherwise;

```Shell
pg_ctl -D . stop -m fast

docker kill -s SIGINT containername
```

- __SIGQUIT__ signals for immediate shutdown. This will leave the database in a improper state and lead to recovery on next startup:

```Shell
pg_ctl -D . stop -m immediate

docker kill -s SIGQUIT containername
```
