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

# Helm Chart for Apache Kafka Connect by Strimzi

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
- [Apache Kafka](https://kafka.apache.org/documentation/#connectconfigs)
- [Confluent Kafka Connect](https://docs.confluent.io/platform/current/connect/index.html)
- [Debezium](https://debezium.io/documentation/reference/stable/index.html)
- [Strimzi](https://strimzi.io/documentation/)
