FROM alpine:3.4

ENV LANG en_US.utf8
ENV PGDATA /var/lib/postgresql

ENV CONFIG_FLAGS="--disable-debug --without-zlib --without-readline"
ENV PACKAGES="curl make gcc g++ linux-headers paxctl libgcc libstdc++"

RUN apk add --no-cache ${PACKAGES} && \
    mkdir ${PGDATA} && chown -R postgres:postgres ${PGDATA} && cd /tmp && \
    curl -o postgresql-9.5.4.tar.gz -sSL https://ftp.postgresql.org/pub/source/v9.5.4/postgresql-9.5.4.tar.gz && \
    curl -o postgresql-9.5.4.tar.gz.sha256 -sSL https://ftp.postgresql.org/pub/source/v9.5.4/postgresql-9.5.4.tar.gz.sha256 && \
    sha256sum -c postgresql-9.5.4.tar.gz.sha256 && \
    tar -zxf postgresql-9.5.4.tar.gz && \
    cd postgresql-9.5.4 && \
    ./configure --prefix=/usr ${CONFIG_FLAGS} && \
    make && make install-strip && \
    cd contrib && make && make install-strip && \
    apk del ${PACKAGES} && \
    rm -rf /etc/ssl /usr/share/man /usr/include /tmp/* /var/cache/apk/*
