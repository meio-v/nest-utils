#/usr/bin/env bash

set -x
set -eo pipefail

if ! [ -x "$(command -v docker)" ]; then
  echo >&2 "Error: Docker Compose not available. Make sure to install Docker on your machine"
  exit 1
fi

if ! docker info > /dev/null 2>&1; then
  echo "This script uses docker, and it isn't running - please start docker and try again!"
  exit 1
fi

if ! [ -x "$(command -v psql)" ]; then
  echo >&2 "Error: psql is not installed."
  exit 1
fi

if ! [ -x "$(command -v sqlx)" ]; then
  echo >&2 "Error: sqlx is not installed."
  echo >&2 "cargo install --version='~0.7' --no-default-features --features rustls,postgres"
  exit 1
fi

DB_USER="${POSTGRES_USER:=postgres}"
DB_PASSWORD="${POSTGRES_PASSWORD:=password}"
DB_NAME="${DB_NAME:=collection-db}"
DB_PORT="${DB_PORT:=5432}"
DB_HOST="${DB_HOST:=localhost}"
REDIS_PORT="${REDIS_PORT:=6379}"

export DB_USER
export DB_PASSWORD
export POSTGRES_DB
export DB_PORT

export REDIS_PORT

cd scripts/artifacts/
docker compose up -d
cd ../../

export PGPASSWORD="${DB_PASSWORD}"
until psql -h "${DB_HOST}" -U "${DB_USER}" -p "${DB_PORT}" -d "postgres" -c '\q'; do 
  >&2 echo "Postgres is still unavailabe - sleeping"
  sleep 1
done

>&2 echo "Postgres is up and running on port ${DB_PORT}"

DATABASE_URL=postgres://${DB_USER}:${DB_PASSWORD}@${DB_HOST}:${DB_PORT}/${DB_NAME}
export DATABASE_URL
# Ensure a clean database state
echo "Dropping existing database if it exists..."
sqlx database drop -f -y

echo "Creating a fresh database..."
sqlx database create

echo "Dropping 'app and app_users' if it exists..."
psql -h "${DB_HOST}" -U "${DB_USER}" -p "${DB_PORT}" -d "${DB_NAME}" -c "
DO \$\$
BEGIN
    IF EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'app_users') THEN
        DROP ROLE app_users;
        DROP GROUP app;
    END IF;
END \$\$;"


echo "Running migrations..."
sqlx migrate run

>&2 echo "Database is clean and ready!"