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

function newTopic()
{
  local topicName=$1
  aws $AWS_FLAGS sns create-topic --name "$topicName"
}
function newQueue()
{
  local queueName=$1
  aws $AWS_FLAGS sqs create-queue --queue-name "$queueName"
}

function snsSubscribeToSqs()
{
  local topicName=$1
  local queueName=$2
  aws $AWS_FLAGS sns subscribe --topic-arn "arn:aws:sns:$REGION:$ACCOUNT_ID:$topicName" --protocol sqs --notification-endpoint "arn:aws:sns:$REGION:$ACCOUNT_ID:$queueName"
}

TOPIC_NAME=${1:-interlok}
QUEUE_NAME=${1:-interlok}
ACTION=${2:-create}

if [ "$ACTION" == "create" ]
then
  newTopic "$TOPIC_NAME"
  ## Sleep a couple of seconds, since the topic creation takes time
  sleep 2
  aws $AWS_FLAGS sns list-topics
  sleep 2
  newQueue "$QUEUE_NAME"
  ## Sleep a couple of seconds, since the queue creation takes time
  sleep 2
  aws $AWS_FLAGS sqs list-queues
  sleep 2
  snsSubscribeToSqs "$TOPIC_NAME" "$QUEUE_NAME"
  ## Sleep a couple of seconds, since the topic creation takes time
  sleep 2
  aws $AWS_FLAGS sns list-subscriptions
fi
