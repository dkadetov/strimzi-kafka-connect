
# Brief instructions on how to work with Strimzi Kafka Connect resources

## How to pause Strimzi Kafka Connect reconciliation

Useful when you can't stop (scale to 0) the Strimzi Operator

```bash
kubectl annotate KafkaConnect <kafka_connector_name> strimzi.io/pause-reconciliation="true"
```

## How to restart connector gracefully

```bash
kubectl annotate KafkaConnector <kafka_connector_name> strimzi.io/restart="true"
```

## How to restart connector task gracefully

Not relevant to the Debezium Connector as it always has only 1 task.

```bash
kubectl annotate KafkaConnector <kafka_connector_name> strimzi.io/restart-task="0"
```

## How to restart strimziPodSet (deployment) gracefully

```bash
kubectl annotate strimzipodset <cluster_name>-connect strimzi.io/manual-rolling-update="true"
```

## How to restart connect pod gracefully

```bash
kubectl annotate pod <cluster_name>-connect-<index_number> strimzi.io/manual-rolling-update="true"
```

## How to pause connector

```bash
kubectl patch KafkaConnector <kafka_connector_name> --type 'merge' --patch '{"spec":{"state":"paused"}}'
```

## How to stop connector

```bash
kubectl patch KafkaConnector <kafka_connector_name> --type 'merge' --patch '{"spec":{"state":"stopped"}}'
```

## How to start connector

```bash
kubectl patch KafkaConnector <kafka_connector_name> --type 'merge' --patch '{"spec":{"state":"running"}}'
```
