#!/usr/bin/env bash

set -e
pkill -9 postgres || true
make install

DB=~/DemoDb
BINDIR=~/project/bin

rm -rf $DB
cp *.sql $BINDIR
cd $BINDIR
./initdb $DB
./pg_ctl -D $DB start
./psql postgres -c "create extension cube;"
./psql postgres -c "create extension ags;"

./psql postgres -c "create table x as select cube(random()) c from generate_series(1,10000) y;"
./psql postgres -c "create index on x using ags(c);"
./psql postgres -c "set enable_bitmapscan to off;explain analyze select * from x where c <@ cube(0,0.1);"
./psql postgres -c "delete from x where (c~>1)>0.1;"

./pg_ctl -D $DB stop
