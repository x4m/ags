FROM ubuntu:18.04
ENV LANG en_US.utf8
ENV HOME /home

RUN apt-get update && apt-get install -y \
    git \
    ca-certificates \
    curl \
    procps \
    sysstat \
    libldap2-dev \
    libpython-dev \
    libreadline-dev \
    libssl-dev \
    bison \
    flex \
    libghc-zlib-dev \
    libcrypto++-dev \
    libxml2-dev \
    libxslt1-dev \
    bzip2 \
    make \
    gcc \
    unzip \
    python \
    locales 
RUN localedef -i en_US -c -f UTF-8 en_US.UTF-8
RUN groupadd -r postgres --gid=999 \
    && useradd -m -r -g postgres --uid=999 postgres
WORKDIR /home/postgres
RUN su postgres -c "git clone https://github.com/postgres/postgres.git --depth=1 --branch=master"
WORKDIR /home/postgres/postgres
COPY . ./contrib/ags
RUN su postgres -c "./configure  \
    --enable-integer-datetimes \
    --enable-thread-safety \
    --with-ldap \
    --with-python \
    --with-openssl \
    --with-libxml \
    --with-libxslt"
RUN make -j 4 install
WORKDIR /home/postgres/postgres/contrib/cube
RUN make install
WORKDIR /home/postgres/postgres/contrib/ags
RUN make install
RUN chown -R postgres:postgres /usr/local/pgsql
# RUN su postgres -c "export PATH=$PATH:/usr/local/pgsql/bin && ./test.sh"
ENV PGINSTALL /usr/local/pgsql
RUN su postgres -c "export PATH=$PATH:/usr/local/pgsql/bin && ./create_replica.sh"
