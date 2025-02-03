
<h1 id="top">Brief instructions on how to work with Debezium PostgreSQL Connector</h1>

**Table of Contents**
- [How to add new tables to an existing Kafka connector](#how-to-add-new-tables-to-an-existing-kafka-connector)
  - [Step 1. Add new tables to the configuration and enable signals](#step-1-add-new-tables-to-the-configuration-and-enable-signals)
  - [Step 2. Trigger an incremental snapshot](#step-2-trigger-an-incremental-snapshot)
  - [Step 3. Check the data in the related Kafka topics](#step-3-check-the-data-in-the-related-kafka-topics)
- [How to proceed if the replication slot is not working](#how-to-proceed-if-the-replication-slot-is-not-working)
- [How to proceed in case of database schema changes](#how-to-proceed-in-case-of-database-schema-changes)
  - [The simplest case](#the-simplest-case)
  - [The most common case](#the-most-common-case)
  - [Complicated case](#complicated-case)
  - [The most complex case](#the-most-complex-case)
    - [Step 1: Clean up snapshot metrics](#step-1-clean-up-snapshot-metrics)
    - [Step 2: Lock the table and trigger the table snapshot](#step-2-lock-the-table-and-trigger-the-table-snapshot)
    - [Step 3: Wait until the snapshot is complete](#step-3-wait-until-the-snapshot-is-complete)
    - [Step 4: Release the table lock and start consumers](#step-4-release-the-table-lock-and-start-consumers)
    - [Example of automating actions](#example-of-automating-actions)

---

<h2 id="how-to-add-new-tables-to-an-existing-kafka-connector">How to add new tables to an existing Kafka connector</h2>

Suppose we need to add the `host` and `notification` tables from the `events` database.

<h3 id="step-1-add-new-tables-to-the-configuration-and-enable-signals">Step 1. Add new tables to the configuration and enable signals</h3>

Edit the `connectorConfig` configuration for the corresponding environment.

Add the tables to `table.include.list` or `topic.creation.*.include`.

Check that the parameter `signal.enabled` is set to `true`.

```yaml
connectorConfig:
  debezium:
    config:
      signal.enabled: true
    instances:
      - name: '{{ $.Release.Name }}-debezium-events-v1'
        config:
          database.dbname: events
          table.include.list: public.event, public.host, public.notification
          topic.creation.group: compacted
          namespace: cloud
      # alternative definition in case when it requires different topic.creation.groups
      - name: '{{ $.Release.Name }}-debezium-events-v2'
        config:
          database.dbname: events
          topic.creation.compacted.include: public.event, public.host
          topic.creation.deleted.include: public.notification
          topic.prefix: cloud
```

<h3 id="step-2-trigger-an-incremental-snapshot">Step 2. Trigger an incremental snapshot</h3>

Detailed explanation: See [Sending signals to a Debezium connector](./HOW-TO-LINKS.md#debezium-documentation)

Connect to the `events` database and insert into the `debezium_signal` table the following information*:

```sql
INSERT INTO debezium.debezium_signal (id, type, data) VALUES (gen_random_uuid(), 'execute-snapshot', '{"data-collections": ["public.host","public.notification"],"type": "incremental"}');
```

(*) Make sure the `pgcrypto` extension is installed for using `gen_random_uuid()` function.

<h3 id="step-3-check-the-data-in-the-related-kafka-topics">Step 3. Check the data in the related Kafka topics</h3>

For the current example, the Kafka topic names will be: `cloud-connect.events.host` and `cloud-connect.events.notification`.

Note: If the table is empty, the Kafka topic will not be created. Kafka Connect will automatically create the topic when the first record is added to the table.

---

<h2 id="how-to-proceed-if-the-replication-slot-is-not-working">How to proceed if the replication slot is not working</h2>

Possible situations when the replication slot is not active or has a huge lag.

If you have a monitoring system, you will receive an alert about it.

Important! Whatever the reason, removing the replication slot is the last resort.

The following describes a typical procedure for diagnosing an issue.

- Check KafkaConnector condition

```bash
kubectl get KafkaConnector -n <strimzi_namespace>
```

- Check KafkaConnector status

```bash
kubectl get KafkaConnector <kafka_connector_name> -n <strimzi_namespace> -o jsonpath='{.status}' | jq
```

- Check `<cluster_name>-connect-*` pod logs 


- Try to restart the connector

```bash
kubectl annotate KafkaConnector <kafka_connector_name> -n <strimzi_namespace> strimzi.io/restart="true"
```

- Do the checks again


One possible reason for the Connector failing is a change in the database schema.

In this case, you will receive a message like this:

```
...
ERROR [<kafka_connector_name>|task-0] WorkerSourceTask{id=<kafka_connector_name>-0} Task threw an uncaught and unrecoverable exception. Task is being killed and will not recover until manually restarted (org.apache.kafka.connect.runtime.WorkerTask) [task-thread-<kafka_connector_name>-0] org.apache.kafka.connect.errors.ConnectException: Tolerance exceeded in error handler
...
Caused by: org.apache.kafka.connect.errors.DataException: Failed to serialize Avro data from topic <topic_name>
...
Caused by: org.apache.kafka.common.errors.SerializationException: Error registering Avro schema ...
...
Caused by: io.confluent.kafka.schemaregistry.client.rest.exceptions.RestClientException: Schema being registered is incompatible with an earlier schema for subject ...
...
```

How to proceed in this case is described in the following section.

---

<h2 id="how-to-proceed-in-case-of-database-schema-changes">How to proceed in case of database schema changes</h2>

There are several scenarios.

However, in all cases, we consider that consumers are ready for a change of scheme

<h3 id="the-simplest-case">The simplest case</h3>

First, the simplest one is when all consumers read a kafka topic only once and never need to reread it.

The following describes a typical procedure:

- stop consumers
- stop the kafka connector
```bash
kubectl patch KafkaConnector <kafka_connector_name> --type 'merge' --patch '{"spec":{"state":"stopped"}}'
```
- delete the kafka topic
```bash
sKafkaNamespace=
sKafkaPodName=
sKafkaContainerName=
sKafkaHomePath="/opt/kafka/bin/" # bitnami case: "/opt/bitnami/kafka/bin" 
sKafkaTopicName=
kubectl -n ${sKafkaNamespace} exec ${sKafkaPodName} -c ${sKafkaContainerName} -- bash -c \
     "export JMX_PORT='' && \
      export KAFKA_HEAP_OPTS=\"-Xmx128M\" && \
      ${sKafkaHomePath}/kafka-topics.sh \
        --bootstrap-server ${sKafkaPodName}:9092 \
        --topic ${sKafkaTopicName} \
        --delete"
```
- delete the schema
```bash
sSRegistryNamespace=
sSRegistryServiceNamespace=
sKafkaTopicName=

kubectl -n ${sSRegistryNamespace} port-forward svc/${sSRegistryServiceNamespace} 8081 &
pfPid=$!
curl -s -X DELETE http://localhost:8081/subjects/${sKafkaTopicName}-value
curl -s -X DELETE http://localhost:8081/subjects/${sKafkaTopicName}-key
kill ${pfPid}
```
- start the kafka connector
```bash
kubectl patch KafkaConnector <kafka_connector_name> --type 'merge' --patch '{"spec":{"state":"running"}}'
```
- check the kafka topic (kafka connector will re-create it on its own)
- start consumers
- make sure that a consumer lag is 0

<h3 id="the-most-common-case">The most common case</h3>

The one case when all consumers are able to reread all data from the topic without suffering any consequences.

Consumer logic should allow for such a scenario, when re-execution of the table snapshot is triggered.

Otherwise, the consumer must have a parameter responsible for skipping `READ` events.

In general, even with a normal replication process using `WAL`, consumers can monitor `LSN` information to determine if an event is a duplicate.

This scenario is completely the same as the previous one, but in addition to it, a snapshot is executed:

```sql
INSERT INTO debezium.debezium_signal (id, type, data) VALUES (gen_random_uuid(), 'execute-snapshot', '{"data-collections": ["public.<table_name>"],"type": "incremental"}');
```

<h3 id="complicated-case">Complicated case</h3>

This scenario assumes that not all consumers are capable of re-reading data from the kafka topic.

Do all the steps described in the first scenario.

If you have the ability to stop the data producer for the database (e.g. a maintenance break), things are greatly simplified:

- stop the data producer
- make sure that a consumer lag is 0
- stop consumers
- delete the kafka topic again
- trigger the table snapshot (in this case use `blocking` type)
- check the kafka topic (kafka connector will re-create it on its own)
- reset consumer's offsets to the end
- start the data producer
- start consumers

<h3 id="the-most-complex-case">The most complex case</h3>

The input conditions are the same as in the previous case, but a maintenance break is **not** possible!

The order of operations is as follows:
- clean up snapshot metrics (1)
- lock the table (2)
- make sure that a consumer lag is 0
- stop consumers
- delete the kafka topic again
- trigger the table snapshot (in this case use `blocking` type)
- wait until the snapshot is complete (3)
- optional: check the kafka topic (kafka connector will re-create it on its own)
- reset consumer's offsets to the end
- release the table lock
- start consumers again

<h4 id="step-1-clean-up-snapshot-metrics">Step 1: Clean up snapshot metrics</h4>

Make sure that debezium metrics are enabled:

```yaml
strimziConfig:
  metricsConfig:
    enabled: true
    debeziumRules: true
```

There is only one way to clear the metrics and that is to restart a pod with a connector.

```bash
sStrimziNamespace="<strimzi_namespace>"
sConnectorName="<kafka_connector_name>"

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

echo "Done"
```

<h4 id="step-2-lock-the-table-and-trigger-the-table-snapshot">Step 2: Lock the table and trigger the table snapshot</h4>

Do this step in a separate console.

```bash
psql -h <server_host> -U <your_username> -d <database_name>
```


```sql
BEGIN;
LOCK TABLE public.<table_name> IN ACCESS EXCLUSIVE MODE;
-- At this point, stop consumers and delete the kafka topic
INSERT INTO debezium.debezium_signal (id, type, data) VALUES (gen_random_uuid(), 'execute-snapshot', '{"data-collections": ["public.<table_name>"],"type": "blocking"}');
-- Wait until the snapshot is complete and reset the consumer offsets to the end. After that do "COMMIT;"
COMMIT;
```

<h4 id="step-3-wait-until-the-snapshot-is-complete">Step 3: Wait until the snapshot is complete</h4>

```bash
sStrimziNamespace="<strimzi_namespace>"
sConnectorName="<kafka_connector_name>"

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

echo "Done"
```

<h4 id="step-4-release-the-table-lock-and-start-consumers">Step 4: Release the table lock and start consumers</h4>

- Reset the consumer offsets to the end
- Do `COMMIT;` on **step #2**
- Start consumers

<h4 id="example-of-automating-actions">Example of automating actions</h4>

See sample [script](/scripts/reinitialize-kafka-connector.sh)
