#!/bin/bash

sStrimziNamespace="<strimzi_namespace>"
sConnectorName="<kafka_connector_name>"

sKafkaNamespace=
sKafkaPodName=
sKafkaContainerName=
sKafkaHomePath="/opt/kafka/bin/" # bitnami image case: "/opt/bitnami/kafka/bin"
sKafkaTopicName=
sKafkaConsumerGroup=

sKafkaConsumerLabel=
sKafkaConsumerNamespace=

sDatabaseHost=
sDatabaseName=
sDatabaseTable=
sDatabaseUser=
sDatabasePass=


echo "Clean up snapshot metrics"
for podName in "$(kubectl get pods -l strimzi.io/kind=KafkaConnect -o name -n ${sStrimziNamespace})"; do
  sSnapshotCompletedMetric=$(kubectl exec ${podName#pod/} -n ${sStrimziNamespace} \
              -- curl -s localhost:9404/metrics | grep "debezium_metrics_SnapshotCompleted" | grep "connector=${sConnectorName}")
  if [[ "${sSnapshotCompletedMetric##* }" == "1.0" ]]; then
    echo "Annotate ${podName}: strimzi.io/manual-rolling-update=\"true\""
    kubectl annotate ${podName} strimzi.io/manual-rolling-update="true" -n ${sStrimziNamespace}
  fi
done

while true; do
  if [ -z $(kubectl get pods -n ${sStrimziNamespace} -o jsonpath='{range .items[?(@.metadata.annotations.strimzi\.io/manual-rolling-update=="true")]}{.metadata.name}{end}') ]; then
    break
  fi
  sleep 5
done
echo "Snapshot metrics cleanup is complete"

echo "Allow 60 seconds for debezium to start"
rm -f /tmp/psql_fifo &> /dev/null
sleep 60

function psql_exec() {
  tail -f /tmp/psql_fifo | psql -f -
}

function psql_stop() {
  echo "COMMIT;" > /tmp/psql_fifo
  echo "\q" > /tmp/psql_fifo
  rm -f /tmp/psql_fifo &> /dev/null

  unset PGHOST
  unset PGDATABASE
  unset PGUSER
  unset PGPASSWORD
}

export PGHOST=${sDatabaseHost}
export PGDATABASE=${sDatabaseName}
export PGPORT=5432
export PGUSER=${sDatabaseUser}
export PGPASSWORD=${sDatabasePass}

mkfifo /tmp/psql_fifo &> /dev/null
psql_exec &
trap psql_stop SIGHUP SIGINT SIGQUIT SIGABRT

echo "Lock the table"
echo "BEGIN;" > /tmp/psql_fifo
echo "LOCK TABLE public.${sDatabaseTable} IN ACCESS EXCLUSIVE MODE;" > /tmp/psql_fifo

echo "Allow 30 seconds for debezium to retrieve the remaining data from the WAL"
sleep 30

echo "Check consumer lag"
while true; do
  sLag=$(kubectl -n ${sKafkaNamespace} exec ${sKafkaPodName} -c ${sKafkaContainerName} -- bash -c \
     "export JMX_PORT='' && \
      export KAFKA_HEAP_OPTS=\"-Xmx128M\" && \
      ${sKafkaHomePath}/kafka-consumer-groups.sh \
        --bootstrap-server ${sKafkaPodName}:9092 \
        --describe \
        --offsets \
        --group ${sKafkaConsumerGroup}" | grep "${sKafkaTopicName}" | awk '{print $6}')
  if grep -qvw "0" <<< ${sLag}; then
    echo "Lag is present. Waiting..."
    echo ${sLag}
  else
    break
  fi
done

echo "Stop consumers"
kubectl scale -l app.kubernetes.io/name==${sKafkaConsumerLabel} deployment,statefulset --namespace=${sKafkaConsumerNamespace} --replicas=0

echo "Delete the kafka topic"
kubectl -n ${sKafkaNamespace} exec ${sKafkaPodName} -c ${sKafkaContainerName} -- bash -c \
   "export JMX_PORT='' && \
    export KAFKA_HEAP_OPTS=\"-Xmx128M\" && \
    ${sKafkaHomePath}/kafka-topics.sh \
      --bootstrap-server ${sKafkaPodName}:9092 \
      --topic ${sKafkaTopicName} \
      --delete"

echo "Trigger the snapshot"
psql -c "INSERT INTO debezium.debezium_signal (id, type, data) VALUES (gen_random_uuid(), 'execute-snapshot', '{\"data-collections\": [\"public.${sDatabaseTable}\"],\"type\": \"blocking\"}');"

echo "Wait until the snapshot is complete"
while true; do
  for podName in "$(kubectl get pods -l strimzi.io/kind=KafkaConnect -o name -n ${sStrimziNamespace})"; do
    sSnapshotCompletedMetric=$(kubectl exec ${podName#pod/} -n ${sStrimziNamespace} \
              -- curl -s localhost:9404/metrics | grep "debezium_metrics_SnapshotCompleted" | grep "connector=${sConnectorName}")
    if [[ "${sSnapshotCompletedMetric##* }" == "1.0" ]]; then
      break 2
    fi
  done
  sleep 5
done
echo "The snapshot completed"

echo "Reset consumer's offsets"
kubectl -n ${sKafkaNamespace} exec ${sKafkaPodName} -c ${sKafkaContainerName} -- bash -c \
   "export JMX_PORT='' && \
    export KAFKA_HEAP_OPTS=\"-Xmx128M\" && \
    ${sKafkaHomePath}/kafka-consumer-groups.sh \
      --bootstrap-server ${sKafkaPodName}:9092 \
      --topic ${sKafkaTopicName} \
      --group ${sKafkaConsumerGroup} \
      --reset-offsets \
      --execute \
      --to-latest"

echo "Release the table lock"
psql_stop

echo "Start consumers"
kubectl scale -l app.kubernetes.io/name==${sKafkaConsumerLabel} deployment,statefulset --namespace=${sKafkaConsumerNamespace} --replicas=1
