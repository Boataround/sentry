#!/bin/bash

#TODO Rename file to update-env.sh

# Fetch the database parameters from AWS SSM
DB_NAME=$(aws ssm get-parameter --name "/Stag/sentry_db_name" --query "Parameter.Value" --output text)
DB_USER=$(aws ssm get-parameter --name "/Stag/sentry_db_user" --query "Parameter.Value" --output text)
DB_PASSWORD=$(aws ssm get-parameter --name "/Stag/sentry_db_password" --query "Parameter.Value" --output text)
DB_HOST=$(aws ssm get-parameter --name "/Stag/sentry_db_host" --query "Parameter.Value" --output text)
DB_PORT=$(aws ssm get-parameter --name "/Stag/sentry_db_port" --query "Parameter.Value" --output text)

# Path to the .env file
ENV_FILE=".env.custom"

# Function to update or add a variable in the .env file
update_env_file() {
    local var_name=$1
    local var_value=$2

    if grep -q "^$var_name=" "$ENV_FILE"; then
        # Variable exists, update it
        sed -i "s/^$var_name=.*/$var_name=$var_value/" "$ENV_FILE"
    else
        # Variable does not exist, add it
        echo "$var_name=$var_value" >> "$ENV_FILE"
    fi
}

# Update or add the environment variables
update_env_file "SENTRY_DB_NAME" "$DB_NAME"
update_env_file "SENTRY_DB_USER" "$DB_USER"
update_env_file "SENTRY_DB_PASSWORD" "$DB_PASSWORD"
update_env_file "SENTRY_DB_HOST" "$DB_HOST"
update_env_file "SENTRY_DB_PORT" "$DB_PORT"

echo ".env file has been updated."
