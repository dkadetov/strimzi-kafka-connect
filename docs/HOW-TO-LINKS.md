
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
- [Associated Projects](#associated-projects)

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

- [Debezium Blog](https://debezium.io/blog/)
- [Main page](https://debezium.io/documentation/reference/stable/index.html)
- [Installing Debezium](https://debezium.io/documentation/reference/stable/install.html)
- [Debezium connector for PostgreSQL](https://debezium.io/documentation/reference/stable/connectors/postgresql.html)
- [Engine Properties](https://debezium.io/documentation/reference/stable/development/engine.html#engine-properties)
- [Handling Failures](https://debezium.io/documentation/reference/stable/development/engine.html#_handling_failures)
- [Behavior when things go wrong](https://debezium.io/documentation/reference/stable/connectors/postgresql.html#postgresql-when-things-go-wrong)
- [Sending signals to a Debezium connector #1](https://github.com/debezium/debezium-examples/blob/main/postgres-kafka-signal/README.md)
- [Sending signals to a Debezium connector #2](https://debezium.io/documentation/reference/stable/configuration/signalling.html)
- [Sending signals to a Debezium connector #3](https://debezium.io/documentation/reference/stable/connectors/postgresql.html#postgresql-triggering-an-incremental-snapshot)
- [Message Filtering](https://debezium.io/documentation/reference/stable/transformations/filtering.html)
- [Content-based routing](https://debezium.io/documentation/reference/stable/transformations/content-based-routing.html)

## Confluent Documentation

- [Kafka Connect Overview](https://docs.confluent.io/platform/current/connect/index.html)
- [Kafka Connect Configuration Reference](https://docs.confluent.io/platform/current/installation/configuration/connect/index.html)
- [Using Kafka Connect with Schema Registry](https://docs.confluent.io/platform/current/schema-registry/connect.html)
- [Configuration Reference for Debezium PostgreSQL Source Connector](https://docs.confluent.io/kafka-connectors/debezium-postgres-source/current/postgres_source_connector_config.html)

## Apache Kafka Connect Documentation

- [Kafka Connect](https://kafka.apache.org/documentation/#connect)
- [Apache Kafka Connect Configs](https://kafka.apache.org/documentation/#connectconfigs)
- [Single Message Transforms](https://kafka.apache.org/documentation.html#connect_transforms)
- [MirrorMaker Configs](https://kafka.apache.org/documentation/#mirrormakerconfigs)
- [Geo-Replication (Cross-Cluster Data Mirroring)](https://kafka.apache.org/documentation/#georeplication)
- [KIP-382: MirrorMaker 2.0](https://cwiki.apache.org/confluence/display/KAFKA/KIP-382%3A+MirrorMaker+2.0)
- [KIP-66: Single Message Transforms for Kafka Connect](https://cwiki.apache.org/confluence/display/KAFKA/KIP-66%3A+Single+Message+Transforms+for+Kafka+Connect)
- [KIP-585: Filter and Conditional SMTs](https://cwiki.apache.org/confluence/display/KAFKA/KIP-585%3A+Filter+and+Conditional+SMTs)

## Red Hat Debezium Documentation

- [Red Hat Debezium Documentation](https://docs.redhat.com/en/documentation/red_hat_build_of_debezium)

## Cloudera Documentation

- [Deployment and Configuration](https://docs.cloudera.com/csm-operator/1.3/kafka-connect-deploy-configure/topics/csm-op-connect-deploying-clusters.html)
- [Operations](https://docs.cloudera.com/csm-operator/1.3/kafka-connect-operations/topics/csm-op-connect-managing-connectors.html)
- [Replication overview](https://docs.cloudera.com/csm-operator/1.3/kafka-replication-overview/topics/csm-op-connect-replication-overview.html)
- [Deploying a replication flow](https://docs.cloudera.com/csm-operator/1.3/kafka-replication-deploy-configure/topics/csm-op-deploying-replications.html)
- [Single Message Transforms](https://docs.cloudera.com/csm-operator/1.3/kafka-connect-operations/topics/kafka-connect-smt-overview.html)
- [Single Message Transforms overview](https://docs.cloudera.com/runtime/7.3.1/kafka-connect/topics/kafka-connect-smt-overview.html)
- [Configuring SMT chain](https://docs.cloudera.com/runtime/7.3.1/kafka-connect/topics/kafka-connect-smt-configuring.html)

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

- [Redpanda: What is Kafka Connect — A complete guide](https://www.redpanda.com/guides/kafka-tutorial-what-is-kafka-connect)
- [Introduction to Kafka Connectors](https://www.baeldung.com/kafka-connectors-guide)
- [Getting started with Kafka Connectors](https://medium.com/@cobch7/kafka-connectors-8fb71ee27cb4)
- [Step-by-Step Guide: Deploying Kafka Connect via Strimzi Operator on Kubernetes](https://itnext.io/step-by-step-guide-deploying-kafka-connect-via-strimzi-operator-on-kubernetes-6357c123abe9)
- [Strimzi — Deploy Kafka in Kubernetes](https://medium.com/@howdyservices9/strimzi-deploy-kafka-in-kubernetes-dd740364861c)
- [Self-Service CDC with Kafka Connect, Crossplane, and Strimzi](https://spoud-io.medium.com/self-service-cdc-with-kafka-connect-crossplane-and-strimzi-8c344122e929)
- [CDC using Debezium in Kubernetes](https://medium.com/@howdyservices9/cdc-using-debezium-in-kubernetes-f41448b7f5db)
- [Change Data Capture (CDC) With Kafka Connect and the Debezium PostgreSQL Source Connector](https://instaclustr.medium.com/change-data-capture-cdc-with-kafka-connect-and-the-debezium-postgresql-source-connector-13a48eabfcb2)
- [Unlocking the Power of Debezium](https://medium.com/payu-engineering/unlocking-the-power-of-debezium-69ce9170f101)
- [Common Challenges Using Debezium and Kafka Connect for CDC](https://olake.io/blog/issues-debezium-kafka)
- [Real-time CDC replications between MySQL and PostgreSQL using Debezium connectors](https://timothyzhang.medium.com/real-time-cdc-replications-between-mysql-and-postgresql-using-debezium-connectors-24aa33d58f1e)
- [Beyond the Basics of Debezium for PostgreSQL](https://medium.com/@arijit.mazumdar/beyond-the-basics-of-debezium-for-postgresql-part-1-d1c6952ae110)
- [Transaction Log Tailing With Debezium — Part 1](https://medium.com/trendyol-tech/transaction-log-tailing-with-debezium-part-1-aeb968d72220)
- [Transaction Log Tailing With Debezium — Part 2](https://medium.com/trendyol-tech/transaction-log-tailing-with-debezium-part-2-9ecaebf063b9)
- [Mastering Kafka Connect: Advanced Source and Sink Configurations](https://www.codefro.com/2024/08/28/mastering-kafka-connect-advanced-source-and-sink-configurations/)
- [Moving data from Kafka to OpenSearch](https://blog.devgenius.io/moving-data-from-kafka-to-opensearch-9ca52d0390fb)
- [How to Set up Kafka and Stream Data to MinIO in Kubernetes](https://blog.min.io/stream-data-to-minio-using-kafka-kubernetes/)
- [Introduction to Schema Registry in Kafka](https://medium.com/slalom-blog/introduction-to-schema-registry-in-kafka-915ccf06b902)
- [Kafka Connect Deep Dive – Converters and Serialization Explained](https://www.confluent.io/blog/kafka-connect-deep-dive-converters-serialization-explained/)
- [Processing Apache Avro-serialized messages from Kafka](https://dalelane.co.uk/blog/?p=5228)
- [How to Use Single Message Transforms in Kafka Connect](https://www.confluent.io/blog/kafka-connect-single-message-transformation-tutorial-with-examples/)
- [Applying transformations selectively](https://debezium.io/documentation/reference/stable/transformations/applying-transformations-selectively.html)
- [Twelve Days of SMT 🎄 Series' Articles](https://dev.to/rmoff/series/10047)
- [Towards Debezium exactly-once delivery](https://debezium.io/blog/2023/06/22/towards-exactly-once-delivery/)
- [Enabling exactly-once semantics](https://docs.cloudera.com/csm-operator/1.3/kafka-replication-deploy-configure/topics/csm-op-enabling-replication-eos.html)
- [Kafka Connector with Custom Transformation](https://hadlakmal.medium.com/kafka-connector-with-custom-transformation-34e29c746c84)
- [Debezium with Single Message Transformation (SMT)](https://medium.com/trendyol-tech/debezium-with-simple-message-transformation-smt-4f5a80c85358)
- [Running the Apache Camel™ HTTP Kafka Source Connector](https://www.instaclustr.com/blog/running-the-apache-camel-http-kafka-source-connector/)
- [Get Your Apache Camel™ Kafka Connectors in a Row](https://www.instaclustr.com/blog/get-your-apache-camel-kafka-connectors-in-a-row/)

## Associated Projects

- [Confluent demo-scene](https://github.com/confluentinc/demo-scene)
- [Fully automated Apache Kafka® and Confluent® Docker based examples](https://github.com/vdesabou/kafka-docker-playground)
- [Camel Kafka Connector](https://camel.apache.org/camel-kafka-connector/)
- [Aiven Connectors & Transformations](https://github.com/Aiven-Open)
- [Generic Kafka Connect transformations from Red Hat](https://github.com/RedHatInsights/connect-transforms)
- [Kafka Connect Common Transformations](https://github.com/jcustenborder/kafka-connect-transform-common)
- [Schema Registry Transfer SMT](https://github.com/OneCricketeer/schema-registry-transfer-smt)
- [Axual Kafka Synchronisation Connectors](https://gitlab.com/axual/public/connect-plugins/kafka-synchronisation-connectors)
- [Record to JSON String SMT](https://github.com/an0r0c/kafka-connect-transform-tojsonstring)
