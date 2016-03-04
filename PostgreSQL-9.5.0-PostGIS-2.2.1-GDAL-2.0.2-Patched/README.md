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

- __CGAL 4.7.__


Usage Pattern
-------------

Build the image directly from Git (this can take a long time):

```Shell
./build.sh
```

or pull it from Docker Hub:

```Shell
docker pull geographica/postgis:postgresql-9.5.0-postgis-2.2.1-gdal-2.0.2-patched
```

The image uses several environment variables. Refer to the Dockerfile for a complete list. The most important one is __POSTGRES_PASSWD__, the password for the user POSTGRES.

The image exposes port 5432, a volume designated by enviroment variable __POSTGRES_DATA_FOLDER__ with the data folder, and another one __POSTGRES_BACKUPS_FOLDER__ for database backups.


Container Creation
------------------

There are several options available to create containers. The most simple one is:

```Shell
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

- __BACKUP_DB:__ semicolon separated names of databases to backup by default. Defaults to _null_, which means no database will be backed-up by default, or to _CREATE_USER_ in case any is used so default database will be backed up automatically. See [Backing Up Databases](Backing Up Databases) for details.

Some examples of container initializations:

```Shell
export PGPASSWD="md5"$(printf '%s' "new_password_here" "postgres" | md5sum | cut -d ' ' -f 1) && \
docker run -d -P --name ageworkshoptestpg -e "POSTGRES_PASSWD=${PGPASSWD}" \
geographica/postgis:postgresql-9.3.5-postgis-2.1.7-gdal-1.11.2-patched 
```

This __run__ command will create a container with a default options, but changing the _postgres_ password to _new_password_here_, and sending it already encrypted to the container. Check [Passwords](Passwords) for details.

```Shell
docker run -d -P --name ageworkshoptestpg -e "LOCALE=es_ES" -e "CREATE_USER=project"  \
-e "CREATE_USER_PASSWD=project_pass" \
geographica/postgis:postgresql-9.3.5-postgis-2.1.7-gdal-1.11.2-patched
```

This will create the container with a spanish locale, and will create on startup an user and database called _project_, being _project_pass_ the password for the _project_ user. Additionaly, the _project_ database is set to be automatically backed up.

```Shell
docker run -d -P --name ageworkshoptestpg -v ./demo_scripts/:/init_scripts/ \
-e "LOCALE=es_ES" -e "CREATE_USER=project"  \
-e "CREATE_USER_PASSWD=project_pass" -e "BACKUP_DB=project" -e \
-e "PSQL_SCRIPTS=/init_scripts/Schema00_DDL.sql;/init_scripts/Schema01_DDL.sql" \
geographica/postgis:postgresql-9.3.5-postgis-2.1.7-gdal-1.11.2-patched
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
geographica/postgis:postgresql-9.3.5-postgis-2.1.7-gdal-1.11.2-patched 
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
geographica/postgis:postgresql-9.3.5-postgis-2.1.7-gdal-1.11.2-patched 
```

_script1.sql_ and _script2.sql_ will be executed on container startup.


Backing Up Databases
--------------------

This image provides a simple method to backup databases with __pg_dump__. Databases to be backed up is controlled by the __BACKUP_DB__ environmental variable. Several scenarios apply:

- __CREATE_USER__ is specified: the default database by the name __CREATE_USER__ will be added automatically as the only database to be backed up;

- __CREATE_USER__ is especified, but so does __BACKUP_DB__ itself: __BACKUP_DB__ takes precedence. So if you want to back up the CREATE_USER database and another one, be sure to include both of them in __BACKUP_DB__ (for example, _userdb;anotherdb_);

- __CREATE_USER__ is not specified: no database will be set for automatic back up;

- __CREATE_USER__ is not specified, but does __BACKUP_DB__: BACKUP_DB takes precedence as normal.

To back up databases, a __docker exec__ is needed:

```shell
docker exec containername make_backups
```

This command accepts data base names as arguments that overrides any __BACKUP_DB__ value:

```shell
docker exec containername make_backups database_a database_b
```

Backups are stored at __POSTGRES_BACKUPS_FOLDER__, which is a exposed volume. Usage patterns may be hard mounting the volume (somewhat dirty) or better linking it to a SFTP or data container for remote retrieval. Backups are time stamped and the backup file has the following format:

```text
[container hash]-[ISO time stamp]-[database name].backup
```


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
