PostgreSQL 9.4.10, PostGIS 2.1.8, GDAL 2.1.1, Patched
=====================================================

<a name="Contents"></a>

Contents
--------

- [Versions](#Versions)
- [Scripts](#Scripts)
- [Image Creation](#Image Creation)
- [Container Creation](#Container Creation)
- [Executing Arbitrary Commands](#Executing Arbitrary Commands)
- [Data Persistence](#Data Persistence)
- [Passwords](#Passwords)
- [Executing psql Scripts on Start Up](#Executing psql Scripts on Start Up)
- [User Mapping](#User Mapping)
- [Backing Up Databases](#Backing Up Databases)
- [Restoring a Database Dump](#Restoring a Database Dump)
- [Configuring the Data Store](#Configuring the Data Store)
- [Killing the Container](#Killing the Container)


<a name="Versions"></a>

Versions
--------

This Dockerfile compiles the following software:

- __PostgreSQL 9.4.10;__

- __GEOS 3.5.0;__

- __Proj 4.9.3:__ patched with the spanish national grid for conversion between ED50 to ETRS89;

- __GDAL 2.1.1:__ also patched;

- __PostGIS 2.1.8:__ patched as well.


<a name="Scripts"></a>

Scripts
-------

There is a script in this repo to help working with this image. __psql-docker__ opens a psql console on a standalone container to connect to other databases. To check how it works:

```Shell
psql-docker -h
```


<a name="Image Creation"></a>

Image Creation
--------------

Build the image directly from Git (this can take a long time):

```Shell
./build.sh
```

or pull it from Docker Hub:

```Shell
docker pull geographica/postgis:deranged_dingo
```

The image exposes port 5432, a volume designated by enviroment variable __POSTGRES_DATA_FOLDER__ with the data folder, and another one __POSTGRES_OUTPUT_FOLDER__ for database output (like backups).


<a name="Container Creation"></a>

Container Creation
------------------

There are several options available to create containers. Check __Usage_Cases__ for testing. The most simple one:

```Shell
docker run -d -P --name pgcontainer \
geographica/postgis:deranged_dingo
```

This will create a container with two default volumes, __/data__ and __/output__, for storing the data store and output, respectively. The default encoding will be __UTF-8__, and the locale __en_US__. No additional modification or action is taken.

Containers can be configured by means of setting environmental variables:

- __POSTGRES_PASSWD:__ set the password for user postgres. See [Passwords](#Passwords) for more details. Defaults to _postgres_;

- __ENCODING:__ encoding to create the data store and the default database, if applicable. Defaults to _UTF-8_;

- __LOCALE:__ locale for the data store and the default database, if any. Defaults to _en_US_;

- __PSQL_SCRIPTS:__ semicolon separated psql scripts to be executed on the data store once created, in absolute path. Defaults to _null_, meaning no action is to be taken. See [Executing psql Scripts on Start Up](#Executing psql Scripts on Start Up) for more details;

- __CREATE_USER:__ creates an user and a default database with this owner at startup. The structure of this parameter is _USERNAME;PASSWORD_, and it defaults to _null;null_, in which case no user and database will be created (very bad luck if you want your user and database to be called 'null' :| ). This user and database are created before any psql script is executed or any backup is restored;

- __BACKUP_DB:__ semicolon separated names of databases to backup by default. Defaults to _null_, which means no database will be backed-up by default, or to _CREATE_USER_ in case any is used so default database will be backed up automatically. See [Backing Up Databases](#Backing Up Databases) for details;

- __PG_RESTORE:__ semicolon separated names of database dumps to be restored. See [Restoring a Database Dump](#Restoring a Database Dump) for details. Defaults to _null_, meaning that no action is to be taken. Restores are done after all psql scripts are executed;

- __UID_FOLDER:__ the folder in the container whose user and group ID must be matched for the postgres user. Defaults to _null_, meaning that the system will try to set the ID. Check [User Mapping](#User Mapping) for details. Please note that Docker for Mac on MacOS Sierra handles nicely the user mapping to the user running Docker, so this is not necessary;

- __PG_HBA:__ configuration of _pg_hba.con_ access file. See [Configuring the Data Store](#Configuring the Data Store) for details;

- __PG_CONF:__ configuration of _postgresql.conf_ See [Configuring the Data Store](#Configuring the Data Store) for details.

Some examples of container initializations:

```Shell
export PGPASSWD="md5"$(printf '%s' "new_password_here" "postgres" | md5sum | cut -d ' ' -f 1) && \
docker run -d -P --name ageworkshoptestpg -e "POSTGRES_PASSWD=${PGPASSWD}" \
geographica/postgis:deranged_dingo 
```

This __run__ command will create a container with a default options, but changing the _postgres_ password to _new_password_here_, and sending it already encrypted to the container. Check [Passwords](#Passwords) for details:

```Shell
docker run -d -P --name ageworkshoptestpg -e "LOCALE=es_ES" -e "CREATE_USER=project"  \
-e "CREATE_USER_PASSWD=project_pass" \
geographica/postgis:deranged_dingo
```

This will create the container with a spanish locale, and will create on startup an user and database called _project_, being _project_pass_ the password for the _project_ user. Additionaly, the _project_ database is set to be automatically backed up.

```Shell
docker run -d -P --name ageworkshoptestpg -v /home/demo_scripts/:/init_scripts/ \
-e "LOCALE=es_ES" -e "CREATE_USER=project"  \
-e "CREATE_USER_PASSWD=project_pass" -e "BACKUP_DB=project" \
-e "PSQL_SCRIPTS=/init_scripts/Schema00_DDL.sql;/init_scripts/Schema01_DDL.sql" \
geographica/postgis:deranged_dingo
```

This one creates a container with a hard-mounted volume from local _demo_scripts_ to container's _/init_scripts_ where a couple of psql scripts will be stored. Creates an user and database called _project_ and executes on it the two mentioned scripts.

Please check folder __Usage_Cases__ for a set of usage cases bundled as a test suite of sorts.


<a name="Executing Arbitrary Commands"></a>

Executing Arbitrary Commands
----------------------------

The image can run arbitrary commands. This is useful for example for creating a temporary container for just dump a database, run a psql session with the one inside this image, or executing scripts into another container.

Some examples:

```Shell
# Interactive pg_dump, will ask for password

docker run --rm -ti -v /whatever/:/d --link the_container_running_the_database:pg \
geographica/postgis:deranged_dingo \
pg_dump -b -E UTF8 -f /d/dump -F c -v -Z 9 -h pg -p 5432 -U postgres project

# Full automatic pg_dump, with password as ENV variable

docker run --rm -v /home/malkab/Desktop/:/d --link test_07:pg \
geographica/postgis:deranged_dingo \
PGPASSWORD="new_password_here" pg_dump -b -E UTF8 -f /d/dump33 -F c \
-v -Z 9 -h pg -p 5432 -U postgres postgres

# Interactive psql

docker run --rm -ti -v /home/malkab/Desktop/:/d --link test_07:pg \ geographica/postgis:deranged_dingo \ PGPASSWORD="new_password_here" psql -h pg -p 5432 -U postgres postgres
```

<a name="Data Persistence"></a>

Data Persistence
----------------

Datastore data can be persisted in a data volume or host mounted folder and be used later by another container. The container checks if __POSTGRES_DATA_FOLDER__ has a file _postgresql.conf_. If not, considers the datastore to be not created and creates an empty one.


<a name="Passwords"></a>

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
geographica/postgis:deranged_dingo
```

Ugly, but effective. Keep in mind, however, that if you use provisioning methods like bash scripts or _Docker Compose_ others will still be able to read passwords from these sources, so keep them safe.


<a name="Executing psql Scripts on Start Up"></a>

Executing psql Scripts on Start Up
----------------------------------

The image can run __psql__ scripts on container's start up. To do so, put scripts inside the container (via a child container image that ADD them from the Dockerfile or mounting a volume) and configure the __PSQL_SCRIPTS__ environment variable. This variable must contain full paths inside the container to psql scripts separated by semicolons (;) that will be executed in order on container startup. For example:

```Shell
export PGPASSWD="md5"$(printf '%s' "password_here" "postgres" | md5sum | cut -d ' ' -f 1) && \
docker run -d -P --name ageworkshoptestpg -e "POSTGRES_PASSWD=${PGPASSWD}" \
-v /localscripts/:/psql_scripts/ \
-e "PSQL_SCRIPTS=/psql_scripts/script1.sql;/psql_scripts/script2.sql" \
geographica/postgis:deranged_dingo
```

_script1.sql_ and _script2.sql_ will be executed on container startup. Scripts are executed as _postgres_.


<a name="User Mapping"></a>

User Mapping
------------

Please note that Docker for Mac on MacOS Sierra handles nicely the user mapping to the user running Docker, so this is not necessary.

The container will create an inner _postgres_ user and group for running the service. The UID and GID of this objects can be adjusted to match one at the host, so files in mounted volumes will be owned by the matched host user. The logic behind user mapping is as follows:

- if the env variable __UID_FOLDER__ is set, the ID will be taken from the given folder;

- if the __output__ exposed volume is mounted to a host folder (like as using the -v option), UID and GID of the owner of the host folder will be read and the container _postgres_ user and group will match them;

- same if __data__ is exposed as a host volume;

- if nothing of the above happens, the user will be created with ID assigned by the system.


<a name="Backing Up Databases"></a>

Backing Up Databases
--------------------

This image provides a simple method to backup databases with __pg_dump__. Databases to be backed up is controlled by the __BACKUP_DB__ environmental variable, with the names of databases separated by a semicolon.

To back up databases, a __docker exec__ is needed:

```shell
docker exec -ti containername make_backups
```

This command accepts data base names as arguments that overrides any __BACKUP_DB__ value:

```shell
docker exec -ti containername make_backups database_a database_b
```

Backups are stored at __POSTGRES_OUTPUT_FOLDER__, which is a exposed volume. Usage patterns may be hard mounting the volume (somewhat dirty) or better linking it to a SFTP or data container for remote retrieval. Backups are time stamped and the backup file has the following format:

```text
[container hash]-[ISO time stamp]-[database name].backup
```

The command used for backups is:

```Shell
pg_dump -b -C -E [encoding] -f [backup file name] -F c -v -Z 9 -h localhost -p 5432 -U postgres [database name]
```


<a name="Restoring a Database Dump"></a>

Restoring a Database Dump
-------------------------

The image allows for restoration of database dumps created by __pg_dump__. The __PG_RESTORE__ environmental variable is used for this. It's a semicolon separated list of parameters for __pg_restore__:

```Shell
-e "PG_RESTORE=-C -F c -v -d postgres -U postgres /path/post1.backup;-d databasename -F c -v -U postgres /path/post2.backup;-C -F c -O -v -d postgres -U postgres post3.backup"
```

As a base, __pg_restore__ is launched with the prefix:

```Shell
pg_restore -h localhost -p 5432
```

Please refer to the __pg_restore__ and __pg_dump__ official documentation for more details. Host is always localhost and port is always 5432, so no need to declare.

Restores are performed after executing any script passed to the container with the __PSQL_SCRIPTS__ variable. If any role must be present at restoration time, create it with a psql script before.


<a name="Configuring the Data Store"></a>

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

Modify this variable to configure at creation time. Keep in mind, however, that any value provided to this variable will supersede the default. Don't forget to include basic access permissions if you modify this variable, or the server will be hardly reachable. For testing purposes, direct commands can be issued via __exec__. Check __Usage Cases__ for examples.

Configuration of __postgresql.conf__ follows an identical procedure. Command is __postgresql_conf__ and has the same syntax as __pg_hba_conf__. The environmental variable is __PG_CONF__, which defaults to the following configuration:

```txt
max_connections=100#listen_addresses='*'#shared_buffers=128MB#dynamic_shared_memory_type=posix#log_timezone='UTC'#datestyle='iso, mdy'#timezone='UTC'#lc_messages='en_US.UTF-8'#lc_monetary='en_US.UTF-8'#lc_numeric='en_US.UTF-8'#lc_time='en_US.UTF-8'#log_statement='all'#log_directory='pg_log'#log_filename='postgresql-%Y-%m-%d_%H%M%S.log'#logging_collector=on#client_min_messages=notice#log_min_messages=notice#log_line_prefix='%a %u %d %r %h %m %i %e'#log_destination='stderr,csvlog'#log_rotation_size=500MB
```

At creation time, language, encoding, and locale info is added based on env variables __LOCALE__ and __ENCODING__.

Logs are stored at __$POSTGRES_DATA_FOLDER/pg_log__.


<a name="Killing the Container"></a>

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

