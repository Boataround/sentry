#!/bin/bash
# This script configures the environment for connecting to an external PostgreSQL database
# and then transfers control to the default entrypoint.

set -e

echo "Preparing to connect to the external PostgreSQL database"

# Ensure the necessary environment variables are set
if [ -z "$SENTRY_DB_NAME" ]; then
  echo "SENTRY_DB_NAME is not set. Exiting."
  exit 1
fi

if [ -z "$SENTRY_DB_USER" ]; then
  echo "SENTRY_DB_USER is not set. Exiting."
  exit 1
fi

if [ -z "$SENTRY_DB_PASSWORD" ]; then
  echo "SENTRY_DB_PASSWORD is not set. Exiting."
  exit 1
fi

if [ -z "$SENTRY_DB_HOST" ]; then
  echo "SENTRY_DB_HOST is not set. Exiting."
  exit 1
fi

if [ -z "$SENTRY_DB_PORT" ]; then
  echo "SENTRY_DB_PORT is not set. Using default port 5432."
  SENTRY_DB_PORT=5432
fi

# Export the environment variables for use by the PostgreSQL client
export PGDATABASE=$SENTRY_DB_NAME
export PGUSER=$SENTRY_DB_USER
export PGPASSWORD=$SENTRY_DB_PASSWORD
export PGHOST=$SENTRY_DB_HOST
export PGPORT=$SENTRY_DB_PORT

echo "Connecting to the external PostgreSQL database at $SENTRY_DB_HOST:$SENTRY_DB_PORT"

# Skip local database initialization steps and directly invoke the default entrypoint
exec /usr/local/bin/docker-entrypoint.sh "$@"


## This script replaces the default docker entrypoint for postgres in the
## development environment.
## Its job is to ensure postgres is properly configured to support the
## Change Data Capture pipeline (by setting access permissions and installing
## the replication plugin we use for CDC). Unfortunately the default
## Postgres image does not allow this level of configurability so we need
## to do it this way in order not to have to publish and maintain our own
## Postgres image.
##
## This then, at the end, transfers control to the default entrypoint.
#
#set -e
#
#prep_init_db() {
#  cp /opt/sentry/init_hba.sh /docker-entrypoint-initdb.d/init_hba.sh
#}
#
#cdc_setup_hba_conf() {
#  # Ensure pg-hba is properly configured to allow connections
#  # to the replication slots.
#
#  PG_HBA="$PGDATA/pg_hba.conf"
#  if [ ! -f "$PG_HBA" ]; then
#    echo "DB not initialized. Postgres will take care of pg_hba"
#  elif [ "$(grep -c -E "^host\s+replication" "$PGDATA"/pg_hba.conf)" != 0 ]; then
#    echo "Replication config already present in pg_hba. Not changing anything."
#  else
#    # Execute the same script we run on DB initialization
#    /opt/sentry/init_hba.sh
#  fi
#}
#
#bind_wal2json() {
#  # Copy the file in the right place
#  cp /opt/sentry/wal2json/wal2json.so $(pg_config --pkglibdir)/wal2json.so
#}
#
#echo "Setting up Change Data Capture"
#
#prep_init_db
#if [ "$1" = 'postgres' ]; then
#  cdc_setup_hba_conf
#  bind_wal2json
#fi
#exec /usr/local/bin/docker-entrypoint.sh "$@"
