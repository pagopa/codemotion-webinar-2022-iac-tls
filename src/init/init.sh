#!/usr/bin/env bash
set -e

#
# Apply the configuration relative to a given subscription
# Subscription are defined in ./subscription
# Usage:
#  ./init.sh SUBSCRIPTION

SUBSCRIPTION=$1
STORAGE_CONTAINERS=("terraform-state")

if [ -z "${SUBSCRIPTION}" ]; then
    printf "\e[1;31mYou must provide a subscription as first argument.\n"
    exit 1
fi

if [ ! -d "./subscriptions/${SUBSCRIPTION}" ]; then
    printf "\e[1;31mYou must provide a subscription for which a variable file is defined. You provided: '%s'.\n" "${SUBSCRIPTION}" > /dev/stderr
    exit 1
fi

# Subscription value setup
az account set -s "${SUBSCRIPTION}"

# shellcheck disable=SC1090
source "./subscriptions/${SUBSCRIPTION}/backend.ini"

# shellcheck disable=SC2154
printf "Subscription: %s\nStorage Account Name: %s\n" "${SUBSCRIPTION}" "${storage_account_name}"

#
# Location value setup
#
echo "The location choosed is: ${location}"

#
# infra-rg setup
#

## create resource group, storage account and blob container if not exixts
# 📦 RG
if [ "$(az group exists --name "${resource_group_name}")" = false ]; then
    az group create --name "${resource_group_name}" --location "${location}"
    echo "[INFO] RG "${resource_group_name}", created"
else
    echo "[INFO] RG "${resource_group_name}", already exists"
fi

# 📚 STORAGE ACCOUNT
# shellcheck disable=SC2046
if [ $(az storage account check-name -n "${storage_account_name}" --query nameAvailable -o tsv) == "true" ]; then
    az storage account create -g "${resource_group_name}" -n "${storage_account_name}" -l "${location}" --sku Standard_ZRS --min-tls-version TLS1_2
    echo "[INFO] storage account: ${storage_account_name}, created"
else
    echo "[INFO] storage account: ${storage_account_name}, already exists"
fi

# 🗄 STORAGE ACCOUNT/CONTAINERS
for container_name in "${STORAGE_CONTAINERS[@]}";
do
    # shellcheck disable=SC2046
    if [ $(az storage container exists --account-name "${storage_account_name}" -n "${container_name}" -o tsv --only-show-errors) == "False" ]; then
        az storage container create -n "${container_name}" --account-name "${storage_account_name}" --only-show-errors
        echo "[INFO] container: ${container_name}, created"
        sleep 30
    else
        echo "[INFO] container: ${container_name}, already exists"
    fi
done

az storage account blob-service-properties update \
  --account-name "${storage_account_name}" \
  --resource-group "${resource_group_name}" \
  --enable-delete-retention true \
  --delete-retention-days 30 \
  --enable-versioning true

echo "[INFO] blob-service-properties updated"

az security atp storage update --is-enabled true \
  --storage-account "${storage_account_name}" \
  --resource-group "${resource_group_name}" \
  --subscription "${SUBSCRIPTION}"

echo "[INFO] security atp storage updated"
