#! /usr/bin/env bash
set -eu

if ! [ -x "$(command -v jq)" ]; then
  if [ -x "$(command -v apk)" ]; then
    apk add jq
  else
    "JQ not avaiable"
    exit 1
  fi
fi


export PYTHONWARNINGS=ignore

ACCOUNT_ID=000000000000
REGION=eu-west-2
ENDPOINT_URL="${ENDPOINT_URL:-https://localhost:4566}"
AWS_FLAGS="--region $REGION --endpoint-url=$ENDPOINT_URL --no-verify-ssl"

function newEncryptKey()
{
  aws $AWS_FLAGS kms create-key --key-usage ENCRYPT_DECRYPT --customer-master-key-spec SYMMETRIC_DEFAULT 
}
function newSignKey()
{
  aws $AWS_FLAGS kms create-key --key-usage SIGN_VERIFY --customer-master-key-spec RSA_4096 
}
function newAlias()
{
  local aliasName=$1
  local keyId=$2
  aws $AWS_FLAGS kms create-alias --alias-name "$aliasName" --target-key-id "$keyId"
}

ALIAS_NAME=${1:-alias/interlok/kms}
ACTION=${2:-create}

if [ "$ACTION" == "create" ]
then
  encryptKeyId=$(newEncryptKey | jq -c -r '.KeyMetadata.KeyId')
  ## Sleep a couple of seconds, since the key creation takes time
  sleep 2
  newAlias "$ALIAS_NAME-encrypt" "$encryptKeyId"
  ## Sleep a couple of seconds, since the alias creation takes time
  sleep 2
  signKeyId=$(newSignKey | jq -c -r '.KeyMetadata.KeyId')
  ## Sleep a couple of seconds, since the key creation takes time
  sleep 2
  newAlias "$ALIAS_NAME-sign" "$signKeyId"
  ## Sleep a couple of seconds, since the alias creation takes time
  sleep 2
  aws $AWS_FLAGS kms list-keys
  aws $AWS_FLAGS kms list-aliases
fi
