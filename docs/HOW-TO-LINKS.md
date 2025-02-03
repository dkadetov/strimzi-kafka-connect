
# External references to documentation

**Table of Contents**
- [Strimzi Documentation](#strimzi-documentation)
    - [Deploying Instructions](#deploying-instructions)
    - [Configuring Instructions](#configuring-instructions)
- [Debezium Documentation](#debezium-documentation)
- [Confluent Documentation](#confluent-documentation)
- [Apache Kafka Connect Documentation](#apache-kafka-connect-documentation)
- [Red Hat Debezium Documentation](#red-hat-debezium-documentation)
- [Cloudera Documentation](#cloudera-documentation)
- [Github Repositories](#github-repositories)
- [Other Useful Links About Kafka-Connect](#other-useful-links-about-kafka-connect)

## Strimzi Documentation

### Deploying Instructions
- [Deploying Kafka Connect](https://strimzi.io/docs/operators/latest/deploying#kafka-connect-str)
- [Adding Kafka Connect connectors](https://strimzi.io/docs/operators/latest/deploying#using-kafka-connect-with-plug-ins-str)
- [Configuring Kafka Connect](https://strimzi.io/docs/operators/latest/deploying#con-kafka-connect-config-str)
- [Configuring Kafka Connect connectors](https://strimzi.io/docs/operators/latest/deploying#con-kafka-connector-config-str)
- [Performing kubectl operations on custom resources](https://strimzi.io/docs/operators/latest/deploying#con-custom-resources-info-str)

### Configuring Instructions
- [KafkaConnectTemplate schema reference](https://strimzi.io/docs/operators/latest/configuring.html#type-KafkaConnectTemplate-reference)
- [PodDisruptionBudgetTemplate schema reference](https://strimzi.io/docs/operators/latest/configuring.html#type-PodDisruptionBudgetTemplate-reference)
- [PodTemplate schema reference](https://strimzi.io/docs/operators/latest/configuring.html#type-PodTemplate-reference)
- [ContainerTemplate schema reference](https://strimzi.io/docs/operators/latest/configuring.html#type-ContainerTemplate-reference)
- [InternalServiceTemplate schema reference](https://strimzi.io/docs/operators/latest/configuring.html#type-InternalServiceTemplate-reference)
- [Condition schema reference](https://strimzi.io/docs/operators/latest/configuring.html#type-Condition-reference)
- [KafkaConnect schema reference](https://strimzi.io/docs/operators/latest/configuring.html#type-KafkaConnect-reference)
- [KafkaConnectStatus schema reference](https://strimzi.io/docs/operators/latest/configuring.html#type-KafkaConnectStatus-reference)
- [KafkaConnector schema reference](https://strimzi.io/docs/operators/latest/configuring.html#type-KafkaConnector-reference)
- [KafkaConnectorStatus schema reference](https://strimzi.io/docs/operators/latest/configuring.html#type-KafkaConnectorStatus-reference)
- [StrimziPodSetStatus schema reference](https://strimzi.io/docs/operators/latest/configuring.html#type-StrimziPodSet-reference)

## Debezium Documentation

- [Main page](https://debezium.io/documentation/reference/stable/index.html)
- [Installing Debezium](https://debezium.io/documentation/reference/stable/install.html)
- [Debezium connector for PostgreSQL](https://debezium.io/documentation/reference/stable/connectors/postgresql.html)
- [Engine Properties](https://debezium.io/documentation/reference/stable/development/engine.html#engine-properties)
- [Handling Failures](https://debezium.io/documentation/reference/stable/development/engine.html#_handling_failures)
- [Behavior when things go wrong](https://debezium.io/documentation/reference/stable/connectors/postgresql.html#postgresql-when-things-go-wrong)
- [Sending signals to a Debezium connector #1](https://github.com/debezium/debezium-examples/blob/main/postgres-kafka-signal/README.md)
- [Sending signals to a Debezium connector #2](https://debezium.io/documentation/reference/stable/configuration/signalling.html)
- [Sending signals to a Debezium connector #3](https://debezium.io/documentation/reference/stable/connectors/postgresql.html#postgresql-triggering-an-incremental-snapshot)

## Confluent Documentation

- [Kafka Connect Overview](https://docs.confluent.io/platform/current/connect/index.html)
- [Kafka Connect Configuration Reference](https://docs.confluent.io/platform/current/installation/configuration/connect/index.html)
- [Using Kafka Connect with Schema Registry](https://docs.confluent.io/platform/7.7/schema-registry/connect.html)

## Apache Kafka Connect Documentation

- [Apache Kafka Connect Configs](https://kafka.apache.org/documentation/#connectconfigs)

## Red Hat Debezium Documentation

- [Red Hat Debezium Documentation](https://docs.redhat.com/en/documentation/red_hat_build_of_debezium)

## Cloudera Documentation

- [Deployment and Configuration](https://docs.cloudera.com/csm-operator/1.1/kafka-connect-deploy-configure/topics/csm-op-connect-deploying-clusters.html)
- [Operations](https://docs.cloudera.com/csm-operator/1.1/kafka-connect-operations/topics/csm-op-connect-managing-connectors.html)

## Github Repositories

- [Debezium](https://github.com/debezium/debezium)
- [Debezium Examples](https://github.com/debezium/debezium-examples)
- [Strimzi Documentation](https://github.com/strimzi/strimzi-kafka-operator/tree/main/documentation)
- [Strimzi Examples](https://github.com/strimzi/strimzi-kafka-operator/tree/main/examples)
- [Strimzi Connect Examples](https://github.com/strimzi/strimzi-kafka-operator/tree/main/examples/connect)
- [Strimzi Metrics Examples](https://github.com/strimzi/strimzi-kafka-operator/blob/main/examples/metrics/kafka-connect-metrics.yaml)
- [Strimzi Grafana Examples](https://github.com/strimzi/strimzi-kafka-operator/blob/main/examples/metrics/grafana-dashboards/strimzi-kafka-connect.json)
- [Strimzi Prometheus Examples](https://github.com/strimzi/strimzi-kafka-operator/blob/main/examples/metrics/prometheus-install/strimzi-pod-monitor.yaml)

## Other Useful Links About Kafka-Connect

- [Step-by-Step Guide: Deploying Kafka Connect via Strimzi Operator on Kubernetes](https://itnext.io/step-by-step-guide-deploying-kafka-connect-via-strimzi-operator-on-kubernetes-6357c123abe9)
- [Strimzi — Deploy Kafka in Kubernetes](https://medium.com/@howdyservices9/strimzi-deploy-kafka-in-kubernetes-dd740364861c)
- [CDC using Debezium in Kubernetes](https://medium.com/@howdyservices9/cdc-using-debezium-in-kubernetes-f41448b7f5db)
- [Change Data Capture (CDC) With Kafka Connect and the Debezium PostgreSQL Source Connector](https://instaclustr.medium.com/change-data-capture-cdc-with-kafka-connect-and-the-debezium-postgresql-source-connector-13a48eabfcb2)
