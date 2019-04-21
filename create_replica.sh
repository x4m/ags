#!/usr/bin/env bash
# Taken from https://github.com/afiskon/pgscripts/blob/master/install.sh

set -e

if [[ -z $PGINSTALL ]]; then
  echo "ERROR: \$PGINSTALL environment variable is empty"
  exit 1
fi

M=$PGINSTALL
U=`whoami`

pkill -9 postgres || true

# rm -rf $M || true
# mkdir $M

make install

$M/bin/initdb -D $M/data-master

# probably not cheap!
echo "wal_consistency_checking = 'all'" >> $M/data-master/postgresql.conf
echo "max_prepared_transactions = 100" >> $M/data-master/postgresql.conf
echo "wal_level = logical" >> $M/data-master/postgresql.conf
echo "wal_keep_segments = 128" >> $M/data-master/postgresql.conf
# keep max_connections large enough or `make installcheck-world` may fail during `prep` test
echo "max_connections = 100" >> $M/data-master/postgresql.conf
echo "wal_log_hints = on" >> $M/data-master/postgresql.conf
echo "max_wal_senders = 8" >> $M/data-master/postgresql.conf
echo "wal_keep_segments = 64" >> $M/data-master/postgresql.conf
echo "listen_addresses = '*'" >> $M/data-master/postgresql.conf
echo "hot_standby = on" >> $M/data-master/postgresql.conf
echo "log_statement = all" >> $M/data-master/postgresql.conf
echo "max_locks_per_transaction = 256" >> $M/data-master/postgresql.conf
#echo "shared_buffers = 1GB" >> $M/data-master/postgresql.conf
#echo "fsync = off" >> $M/data-master/postgresql.conf
#echo "autovacuum = off" >> $M/data-master/postgresql.conf

echo "host replication $U 127.0.0.1/24 trust" >> $M/data-master/pg_hba.conf
echo "host all $U 127.0.0.1/24 trust" >> $M/data-master/pg_hba.conf
echo "host all all 10.128.0.0/16 trust" >> $M/data-master/pg_hba.conf

# CREATE ROLE scram_role LOGIN PASSWORD ('pass' USING 'scram');
# CREATE DATABASE scram_role;
# GRANT ALL privileges ON DATABASE scram_role TO scram_role;
# psql -U scram_role

echo '' > $M/data-master/logfile

echo "=== STARTING MASTER ==="

$M/bin/pg_ctl -w -D $M/data-master -l $M/data-master/logfile start
# $M/bin/createdb $U
$M/bin/psql -c "create table test(k int primary key, v text);"

echo "=== RUNNING PG_BASEBACKUP ==="

$M/bin/pg_basebackup -P -R -X stream -c fast -h 127.0.0.1 -U $U -D $M/data-slave
echo "port = 5433" >> $M/data-slave/postgresql.conf

echo "=== STARTING SLAVE ==="

$M/bin/pg_ctl -w -D $M/data-slave -l $M/data-slave/logfile start

$M/bin/psql postgres -c "create extension cube;"
$M/bin/psql postgres -c "create extension ags;"

$M/bin/psql postgres -c "create table x as select cube(random()) c from generate_series(1,10000) y;"
$M/bin/psql postgres -c "create index on x using ags(c);"
$M/bin/psql postgres -c "set enable_bitmapscan to off;explain analyze select * from x where c <@ cube(0,0.1);"
$M/bin/psql postgres -c "delete from x where (c~>1)>0.1;"