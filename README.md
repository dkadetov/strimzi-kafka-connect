```text
 ____  _        _               _                                                       
/ ___|| |_ _ __(_)_ __ ___  ___(_)                                                      
\___ \| __| '__| | '_ ` _ \|_  / |                                                      
 ___) | |_| |  | | | | | | |/ /| |                                                      
|____/ \__|_|  |_|_| |_| |_/___|_|  __ _            ____                            _   
                        | |/ /__ _ / _| | ____ _   / ___|___  _ __  _ __   ___  ___| |_ 
              _ _   _   | ' // _` | |_| |/ / _` | | |   / _ \| '_ \| '_ \ / _ \/ __| __|
    __      _(_) |_| |__| . \ (_| |  _|   < (_| | | |__| (_) | | | | | | |  __/ (__| |_ 
    \ \ /\ / / | __| '_ \_|\_\__,_|_| |_|\_\__,_|  \____\___/|_| |_|_| |_|\___|\___|\__|
 ____\ V  V /| | |_| | | | _                                                            
|  _ \\_/\_/ |_|\__|_| |_|(_)_   _ _ __ ___                                             
| | | |/ _ \ '_ \ / _ \_  / | | | | '_ ` _ \                                            
| |_| |  __/ |_) |  __// /| | |_| | | | | | |                                           
|____/ \___|_.__/ \___/___|_|\__,_|_| |_| |_|                                             
```

# Helm Chart for Apache Kafka Connect

This project is an attempt to implement a declarative approach to managing connectors for **Apache Kafka Connect**.

The **Strimzi Cluster Operator** supports many resources specific to Apache Kafka, including `KafkaConnect` and `KafkaConnector`.
However, Strimzi does not offer official Helm Charts to simplify the configuration and deployment of such resources.

This Helm Chart was created to fill this gap.

Currently, the chart supports and has been tested with one type of connector: the **Debezium PostgreSQL Connector**.
That said, there is nothing preventing you from adding other connectors as needed.

The project also includes:
- [Dockerfile](/Dockerfile) containing a basic example for building an image with the necessary plugins.
- [Documentation](/docs) briefly describing the configuration capabilities of the chart and working with connectors:
  - [External references to the official documentation](/docs/HOW-TO-LINKS.md)
  - [How to install the Helm Chart](/docs/HOW-TO-INSTALL.md)
  - [How to configure the Helm Chart](/docs/HOW-TO-CONFIGURE.md)
  - [How to work with Strimzi Kafka Connect resources](/docs/HOW-TO-STRIMZI.md)
  - [How to work with the Debezium PostgreSQL Connector](/docs/HOW-TO-DEBEZIUM.md)
  - [How to work with PostgreSQL in the Debezium context](/docs/HOW-TO-POSTGRES.md)

It is highly recommended to first familiarize yourself with the official documentation:
- [Apache Kafka](https://kafka.apache.org/documentation/#connect)
- [Confluent Kafka Connect](https://docs.confluent.io/platform/current/connect/index.html)
- [Debezium](https://debezium.io/documentation/reference/stable/index.html)
- [Strimzi](https://strimzi.io/documentation/)

---

## What's new in version 1.1.0: `separator` connector

Although this project is based on the **Debezium PostgreSQL Connector** implementation, it was decided to add support for another connector to avoid duplicating the core logic of the Helm Chart in a separate project.

The goal was to forward the contents of certain Kafka topics, after applying filtering, to an external system (such as Azure Event Hub).

**MirrorSourceConnector**, the core component of **Apache Kafka MirrorMaker** (version 2), was chosen as a foundation.

### Challenges and Solutions

Since **MirrorSinkConnector** is still unavailable and **MirrorSourceConnector** is inherently a source-type connector, we encountered several issues when using it as a sink-type connector:
- In this usage scenario, `key.converter` and `value.converter` settings are not applied.
- However, deserialization (in our case, using Avro schema) is mandatory due to the need to filter messages based on specific criteria.

To address this:
- A specialized [Cloudera](/docs/HOW-TO-LINKS.md#cloudera-documentation) `transformations` library was used to handle deserialization/serialization at `SMT` level.
- For message filtering, was used [Debezium](/docs/HOW-TO-LINKS.md#debezium-documentation) scripting library (with groovy script engine implementation): `debezium-scripting`.

Additionally, the default replication policy (`replication.policy.class`) was replaced:
- Instead of using `org.apache.kafka.connect.mirror.DefaultReplicationPolicy`, we adopted `org.apache.kafka.connect.mirror.IdentityReplicationPolicy`.
- `DefaultReplicationPolicy` adds the prefix `${source.cluster.alias}${replication.policy.separator}` (e.g., `source-`) to the output topic name.
- Since we are using a source-type connector, this prefix affects how `io.confluent.connect.avro.AvroConverter` processes the Avro schema.
- As a result, the Avro schema will not be found because it does not include this prefix.
- However, this approach comes with additional considerations:
  - We need to add a prefix to the output topic differently (this is required when using a single Kafka cluster, such as in a demo setup).
  - Topic parameters will not be replicated automatically, so we have to manage this manually.

For further details:
- The [values.yaml](/helm/strimzi-kafka-connect/values.yaml) file provides some additional explanations.
- The [values-test.yaml](/helm/values-test.yaml) file contains a basic usage example.
