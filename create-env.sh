#!/bin/bash

# Fetch the database parameters from AWS SSM
DB_NAME=$(aws ssm get-parameter --name "/Stag/sentry_db_name" --query "Parameter.Value" --output text)
DB_USER=$(aws ssm get-parameter --name "/Stag/sentry_db_user" --query "Parameter.Value" --output text)
DB_PASSWORD=$(aws ssm get-parameter --name "/Stag/sentry_db_password" --query "Parameter.Value" --output text)
DB_HOST=$(aws ssm get-parameter --name "/Stag/sentry_db_host" --query "Parameter.Value" --output text)
DB_PORT=$(aws ssm get-parameter --name "/Stag/sentry_db_port" --query "Parameter.Value" --output text)

# Create .env file and write the parameters
cat <<EOF > .env
SENTRY_DB_NAME=$DB_NAME
SENTRY_DB_USER=$DB_USER
SENTRY_DB_PASSWORD=$DB_PASSWORD
SENTRY_DB_HOST=$DB_HOST
SENTRY_DB_PORT=$DB_PORT
EOF

echo ".env file created with database parameters"
