PostgreSQL Base
---------------

Mini version of PostgreSQL v9.5.4 Base Docker Images – built on [Alpine Linux](https://alpinelinux.org/).

This is the postgresql base version. If you want ready-to-run version, get [lontongcorp/postgresql](https://hub.docker.com/r/lontongcorp/postgresql/). Base version includes all `extension` contrib from original source code.

Create Dockerfile
--------

Create your own Dockerfile based on this `base` image:

    FROM lontongcorp/postgresql-base

    ENV LANG en_US.utf8
    ENV PGDATA /var/lib/postgresql
    ENV PGPASS 'mySecretP4s$word'

    RUN su - postgres -c "/usr/bin/initdb -D ${PGDATA}" && \
        su - postgres -c "/usr/bin/pg_ctl -D ${PGDATA} start" && \
        sleep 2s && \
        psql -U postgres -c "ALTER ROLE postgres WITH PASSWORD '${PGPASS}'" && \
        su - postgres -c "/usr/bin/pg_ctl -D ${PGDATA} stop" && \
        echo "local all all md5" > ${PGDATA}/pg_hba.conf && \
        echo "host all all 0.0.0.0/0 md5" >> ${PGDATA}/pg_hba.conf && \
        echo "listen_addresses='*'" >> ${PGDATA}/postgresql.conf

    EXPOSE 5432

    USER postgres

    CMD ["/usr/bin/postgres"]


Another example to remove all local cli, clean all database templates on initdb (except template1 used for `CREATE DATABASE`), input and run your sql data:

    FROM lontongcorp/postgresql-base

    ENV LANG en_US.utf8
    ENV PGDATA /var/lib/postgresql
    ENV PGPASS 'mySecretP4ssword'

    COPY my_data.sql /tmp/my_data.sql
    ENV MYDB mydb

    RUN su - postgres -c "/usr/bin/initdb -D ${PGDATA}" && \
        su - postgres -c "/usr/bin/pg_ctl -D ${PGDATA} start" && \
        sleep 2s && \
        psql -U postgres -d template1 -c "UPDATE pg_database SET datistemplate='false' WHERE datname IN ('template0', 'postgres');" && \
        psql -U postgres -d template1 -c "DROP DATABASE template0;" && \
        psql -U postgres -d template1 -c "DROP DATABASE postgres;" && \
        psql -U postgres -d template1 -c "ALTER ROLE postgres WITH PASSWORD '${PGPASS}'" && \
        psql -U postgres -d template1 -c "CREATE DATABASE ${MYDB}" && \
        psql -U postgres -d ${MYDB} -c "CREATE EXTENSION hstore" && \
        psql -U postgres -d ${MYDB} -f /tmp/my_data.sql && \
        su - postgres -c "/usr/bin/pg_ctl -D ${PGDATA} stop" && \
        echo "local all all md5" > ${PGDATA}/pg_hba.conf && \
        echo "host all all 0.0.0.0/0 md5" >> ${PGDATA}/pg_hba.conf && \
        echo "listen_addresses='*'" >> ${PGDATA}/postgresql.conf

    EXPOSE 5432

    USER postgres

    CMD ["/usr/bin/postgres"]


Run:

    docker run -d --name postgresql --restart unless-stopped -it -p 5432:5432 <username>/postgresql

Credits
-------

Inspired by:

- https://hub.docker.com/r/anapsix/pgsql/ (small but exclude extensions)
- https://hub.docker.com/r/mhart/alpine-node/ (for idea building from source with alpine)
