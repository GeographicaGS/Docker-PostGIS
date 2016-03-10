PostgreSQL 9.5.0, PostGIS 2.2.1, GDAL 2.0.2, Patched
=====================================================

Versions
--------

This Dockerfile compiles the following software:

- __PostgreSQL 9.5.0;__

- __GEOS 3.5.0;__

- __Proj 4.9.2:__ patched with the spanish national grid for conversion between ED50 to ETRS89;

- __GDAL 2.0.2:__ also patched;

- __Postgis 2.2.1:__ patched as well;

- __CGAL 4.6.3;__

- __SFCGAL 1.3.0.__


Image Creation
--------------

Build the image directly from Git (this can take a long time):

```Shell
./build.sh
```

or pull it from Docker Hub:

```Shell
docker pull geographica/postgis:postgresql-9.5.0-postgis-2.2.1-gdal-2.0.2-patched
```

The image exposes port 5432, a volume designated by enviroment variable __POSTGRES_DATA_FOLDER__ with the data folder, and another one __POSTGRES_BACKUPS_FOLDER__ for database backups.


Container Creation
------------------

There are several options available to create containers. Check __container_creation_examples__ for testing. The most simple one:

```Shell
# Simple.sh

docker run -d -P --name pgcontainer \ geographica/postgis:postgresql-9.5.0-postgis-2.2.1-gdal-2.0.2-patched
```

This will create a container with two volumes, __/data__ and __/backups__, for storing the data store and backups, respectively. The default encoding will be __UTF-8__, and the locale __en_US__. No additional modification or action is taken.

Containers can be configured by means of setting environmental variables:

- __POSTGRES_PASSWD:__ set the password for user postgres. See [Passwords](Passwords) for more details. Defaults to _postgres_;

- __POSTGRES_DATA_FOLDER:__ in the rare case the data store folder is to be changed. Defaults to _/data_;

- __POSTGRES_BACKUPS_FOLDER:__ in the even more rare case the backup folder must be reassigned. Defaults to _/backups_;

- __ENCODING:__ encoding to create the data store and the default database, if applicable. Defaults to _UTF-8_;

- __LOCALE:__ locale for the data store and the default database, if any. Defaults to _en_US_;

- __PSQL_SCRIPTS:__ psql scripts to be executed on the data store once created. See [Executing psql Scripts on Start Up](Executing psql Scripts on Start Up) for more details;

- __CREATE_USER:__ creates an user and a default database with this owner at startup. Defaults to _null_, in which case no user and database will be created (very bad luck if you want your user and database to be called 'null' :| );

- __CREATE_USER_PASSWD:__ set the password for the aforementioned user. See [Passwords](Passwords) for more details. Defaults to _null_;

- __BACKUP_DB:__ semicolon separated names of databases to backup by default. Defaults to _null_, which means no database will be backed-up by default, or to _CREATE_USER_ in case any is used so default database will be backed up automatically. See [Backing Up Databases](Backing Up Databases) for details;

- __PG_HBA:__ configuration of _pg_hba.con_ access file. See [Configuring the Data Store](Configuring the Data Store) for details;

- __PG_CONF:__ configuration of _postgresql.conf_ See [Configuring the Data Store](Configuring the Data Store) for details.

Some examples of container initializations:

```Shell
# With_passwords.sh

export PGPASSWD="md5"$(printf '%s' "new_password_here" "postgres" | md5sum | cut -d ' ' -f 1) && \
docker run -d -P --name ageworkshoptestpg -e "POSTGRES_PASSWD=${PGPASSWD}" \
geographica/postgis:postgresql-9.5.0-postgis-2.2.1-gdal-2.0.2-patched 
```

This __run__ command will create a container with a default options, but changing the _postgres_ password to _new_password_here_, and sending it already encrypted to the container. Check [Passwords](Passwords) for details:

```Shell
# Create_user.sh

docker run -d -P --name ageworkshoptestpg -e "LOCALE=es_ES" -e "CREATE_USER=project"  \
-e "CREATE_USER_PASSWD=project_pass" \
geographica/postgis:postgresql-9.5.0-postgis-2.2.1-gdal-2.0.2-patched
```

This will create the container with a spanish locale, and will create on startup an user and database called _project_, being _project_pass_ the password for the _project_ user. Additionaly, the _project_ database is set to be automatically backed up.

```Shell
# With_scripts.sh

docker run -d -P --name ageworkshoptestpg -v /home/demo_scripts/:/init_scripts/ \
-e "LOCALE=es_ES" -e "CREATE_USER=project"  \
-e "CREATE_USER_PASSWD=project_pass" -e "BACKUP_DB=project" \
-e "PSQL_SCRIPTS=/init_scripts/Schema00_DDL.sql;/init_scripts/Schema01_DDL.sql" \
geographica/postgis:postgresql-9.5.0-postgis-2.2.1-gdal-2.0.2-patched
```

This one creates a container with a hard-mounted volume from local _demo_scripts_ to container's _/init_scripts_ where a couple of psql scripts will be stored. Creates an user and database called _project_ and executes on it the two mentioned scripts.


Passwords
---------

Passwords sent to the container with environment variables __POSTGRES_PASSWD__ and __CREATE_USER_PASSED__ can be passed either on plain text or already encrypted á la PostgreSQL. To pass it on plain text means that anybody with access to the __docker inspect__ command on the server will be able to read passwords. Encrypting them previously means that __docker inspect__ will show the encrypted password, adding an additional layer of secrecy.

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
geographica/postgis:postgresql-9.5.0-postgis-2.2.1-gdal-2.0.2-patched
```

Ugly, but effective. Keep in mind, however, that if you use provisioning methods like bash scripts or _Docker Compose_ others will still be able to read passwords from these sources, so keep them safe.


Executing psql Scripts on Start Up
----------------------------------

The image can run __psql__ scripts on container's start up. To do so, put scripts inside the container (via a child container image that ADD them from the Dockerfile or mounting a volume) and configure the __PSQL_SCRIPTS__ environment variable. This variable must contain full paths inside the container to psql scripts separated by semicolons (;) that will be executed in order on container startup. For example:

```Shell
export PGPASSWD="md5"$(printf '%s' "password_here" "postgres" | md5sum | cut -d ' ' -f 1) && \
docker run -d -P --name ageworkshoptestpg -e "POSTGRES_PASSWD=${PGPASSWD}" \
-v /localscripts/:/psql_scripts/ \
-e "PSQL_SCRIPTS=/psql_scripts/script1.sql;/psql_scripts/script2.sql" \
geographica/postgis:postgresql-9.5.0-postgis-2.2.1-gdal-2.0.2-patched
```

_script1.sql_ and _script2.sql_ will be executed on container startup. Scripts are executed as _postgres_.


Backing Up Databases
--------------------

This image provides a simple method to backup databases with __pg_dump__. Databases to be backed up is controlled by the __BACKUP_DB__ environmental variable. Several scenarios apply:

- __CREATE_USER__ is specified: the default database by the name __CREATE_USER__ will be added automatically as the only database to be backed up;

- __CREATE_USER__ is especified, but so does __BACKUP_DB__ itself: __BACKUP_DB__ takes precedence. So if you want to back up the CREATE_USER database and another one, be sure to include both of them in __BACKUP_DB__ (for example, _userdb;anotherdb_);

- __CREATE_USER__ is not specified: no database will be set for automatic back up;

- __CREATE_USER__ is not specified, but does __BACKUP_DB__: BACKUP_DB takes precedence as normal.

To back up databases, a __docker exec__ is needed:

```shell
docker exec -ti containername make_backups
```

This command accepts data base names as arguments that overrides any __BACKUP_DB__ value:

```shell
docker exec -ti containername make_backups database_a database_b
```

Backups are stored at __POSTGRES_BACKUPS_FOLDER__, which is a exposed volume. Usage patterns may be hard mounting the volume (somewhat dirty) or better linking it to a SFTP or data container for remote retrieval. Backups are time stamped and the backup file has the following format:

```text
[container hash]-[ISO time stamp]-[database name].backup
```


Configuring the Data Store
--------------------------

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
docker exec -ti whatevercontainer pg_hba_conf a "host all all 23.123.22.1/32 trust#host all all 93.32.12.3/32 md5"
```

but at startup it is controlled by an environment variable, __PG_HBA__, which defaults to:

```txt
ENV PG_HBA "local all all trust#host all all 127.0.0.1/32 trust#host all all 0.0.0.0/0 md5#host all all ::1/128 trust"
```

Modify this variable to configure at creation time. Obviously, for testing purposes, direct commands can be issued via __exec__.

Configuration of __postgresql.conf__ follows an identical procedure. Command is __postgresql_conf__ and has the same syntax as __pg_hba_conf__. The environmental variable is __PG_CONF__, which defaults to:

```txt
ENV PG_CONF "max_connections=100#listen_addresses='*'#shared_buffers=128MB#dynamic_shared_memory_type=posix#log_timezone='UTC'#datestyle='iso, mdy'#timezone='UTC'"
```

At creation time, language, encoding, and locale info is added based on env variables __LOCALE__ and __ENCODING__.


Killing the Container
---------------------

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
