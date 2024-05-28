#!/bin/bash

_group="Setting up / migrating database ..."

# Check required environment variables
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

# Wait for the external PostgreSQL database to be ready
RETRIES=5
until psql -h "$SENTRY_DB_HOST" -U "$SENTRY_DB_USER" -d "$SENTRY_DB_NAME" -c "select 1" >/dev/null 2>&1 || [ $RETRIES -eq 0 ]; do
  echo "Waiting for PostgreSQL server at $SENTRY_DB_HOST:$SENTRY_DB_PORT, $((RETRIES--)) remaining attempts..."
  sleep 1
done

if [ $RETRIES -eq 0 ]; then
  echo "Failed to connect to PostgreSQL server at $SENTRY_DB_HOST:$SENTRY_DB_PORT. Exiting."
  exit 1
fi

# Fixes https://github.com/getsentry/self-hosted/issues/2758, where a migration fails due to indexing issue
psql -h "$SENTRY_DB_HOST" -U "$SENTRY_DB_USER" -d "$SENTRY_DB_NAME" -qAt -c "ALTER TABLE IF EXISTS sentry_groupedmessage DROP CONSTRAINT IF EXISTS sentry_groupedmessage_project_id_id_515aaa7e_uniq;"
psql -h "$SENTRY_DB_HOST" -U "$SENTRY_DB_USER" -d "$SENTRY_DB_NAME" -qAt -c "DROP INDEX IF EXISTS sentry_groupedmessage_project_id_id_515aaa7e_uniq;"

#PGPASSWORD="$SENTRY_DB_PASSWORD" psql -h "$SENTRY_DB_HOST" -U "$SENTRY_DB_USER" -d "$SENTRY_DB_NAME" -qAt -c "ALTER TABLE IF EXISTS sentry_groupedmessage DROP CONSTRAINT IF EXISTS sentry_groupedmessage_project_id_id_515aaa7e_uniq;"
#PGPASSWORD="$SENTRY_DB_PASSWORD" psql -h "$SENTRY_DB_HOST" -U "$SENTRY_DB_USER" -d "$SENTRY_DB_NAME" -qAt -c "DROP INDEX IF EXISTS sentry_groupedmessage_project_id_id_515aaa7e_uniq;"

if [[ -n "${CI:-}" || "${SKIP_USER_CREATION:-0}" == 1 ]]; then
  $dcr web upgrade --noinput
  echo ""
  echo "Did not prompt for user creation. Run the following command to create one yourself (recommended):"
  echo ""
  echo "  $dc_base run --rm web createuser"
  echo ""
else
  $dcr web upgrade
fi

echo "${_endgroup}"



#echo "${_group}Setting up / migrating database ..."
#
## Fixes https://github.com/getsentry/self-hosted/issues/2758, where a migration fails due to indexing issue
#$dc up -d postgres
## Wait for postgres
#RETRIES=5
#until $dc exec postgres psql -U postgres -c "select 1" >/dev/null 2>&1 || [ $RETRIES -eq 0 ]; do
#  echo "Waiting for postgres server, $((RETRIES--)) remaining attempts..."
#  sleep 1
#done
#$dc exec postgres psql -qAt -U postgres -c "ALTER TABLE IF EXISTS sentry_groupedmessage DROP CONSTRAINT IF EXISTS sentry_groupedmessage_project_id_id_515aaa7e_uniq;"
#$dc exec postgres psql -qAt -U postgres -c "DROP INDEX IF EXISTS sentry_groupedmessage_project_id_id_515aaa7e_uniq;"
#
#if [[ -n "${CI:-}" || "${SKIP_USER_CREATION:-0}" == 1 ]]; then
#  $dcr web upgrade --noinput
#  echo ""
#  echo "Did not prompt for user creation. Run the following command to create one"
#  echo "yourself (recommended):"
#  echo ""
#  echo "  $dc_base run --rm web createuser"
#  echo ""
#else
#  $dcr web upgrade
#fi
#
#echo "${_endgroup}"
