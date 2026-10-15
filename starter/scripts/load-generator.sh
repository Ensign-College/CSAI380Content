#!/usr/bin/env sh
# Floods a Kafka topic with events to trigger the HPA (5.4 Part Four).
# Usage: ./load-generator.sh <namespace> [topic] [count]
set -eu

NAMESPACE="${1:?usage: load-generator.sh <namespace> [topic] [count]}"
TOPIC="${2:-practice-events}"
COUNT="${3:-50000}"

kubectl exec -i "kafka-controller-0" -n "$NAMESPACE" -- sh -c "
  seq 1 $COUNT | sed 's/^/{\"event_id\": /; s/\$/, \"type\": \"load-test\"}/' |
  kafka-console-producer.sh --bootstrap-server localhost:9092 --topic $TOPIC
"
echo "Produced $COUNT events to $TOPIC"
