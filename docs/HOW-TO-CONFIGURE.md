
# Brief instructions on how to configure the Helm Chart

---

**Table of Contents**
- [Helm Chart Structure](#helm-chart-structure)
  - [`clusterOperator`](#-clusteroperator)
  - [`commonLabels`](#-commonlabels)
  - [`commonAnnotations`](#-commonannotations)
  - [`strimziConfig`](#-strimziconfig)
    - [`strimziConfig.metricsConfig`](#-metricsconfig)
    - [`strimziConfig.loggingConfig`](#-loggingconfig)
    - [`strimziConfig.tracingConfig`](#-tracingconfig)
  - [`deploymentConfig`](#-deploymentconfig)
  - [`connectConfig`](#-connectconfig)
  - [`externalConfig`](#-externalconfig)
    - [`rbac`](#-rbac)
    - [`podMonitor`](#-podmonitor)
    - [`configMap`](#-configmap)
    - [`secret`](#-secret)
    - [`debeziumConfig`](#-debeziumconfig)
    - [`extraManifests`](#-extramanifests)
- [Notes](#notes)
- [Special Note on `tracingConfig`](#special-note-on-tracingconfig)

---

This is, in fact, a very brief and superficial configuration guide.

It does not claim to provide a complete description or explanation of all possible parameters.

It is assumed that you have a basic understanding of the structure of Helm charts and Kubernetes (k8s) deployments.

It is highly recommended to start by reviewing the documentation at:
- [Apache Kafka](./HOW-TO-LINKS.md#apache-kafka-connect-documentation)
- [Confluent Kafka Connect](./HOW-TO-LINKS.md#confluent-documentation)
- [Debezium](./HOW-TO-LINKS.md#debezium-documentation)
- [Strimzi](./HOW-TO-LINKS.md#strimzi-documentation)

Below is the chart structure and only a few specific features.

## Helm Chart Structure

| Parameter                                  | Description                                                                    |
|--------------------------------------------|--------------------------------------------------------------------------------|
| [`clusterOperator`](#-clusteroperator)     | Optional inclusion and configuration of the child strimzi-kafka-operator chart |
| [`commonLabels`](#-commonlabels)           | Labels applied to all resources created by this chart                          |
| [`commonAnnotations`](#-commonannotations) | Annotations applied to all resources created by this chart                     |
| [`strimziConfig`](#-strimziconfig)         | Settings specific to the use of the Strimzi Operator                           |
| [`deploymentConfig`](#-deploymentconfig)   | Settings directly related to the deployment                                    |
| [`connectConfig`](#-connectconfig)         | Settings specific to Kafka Connect                                             |
| [`connectorConfig`](#-connectorconfig)     | Settings specific to Kafka Connector                                           |
| [`externalConfig`](#-externalconfig)       | Settings related to additional resources created by this chart                 |

### ⦿ clusterOperator

Since using this chart requires the installation of the Strimzi Cluster Operator, it is included as a dependency in the form of a child chart.

By default, the installation of the Strimzi Cluster Operator is not enabled.

Please note that some settings have been modified compared to the original and are for demonstration purposes.

### ⦿ commonLabels

All resources created by this chart will include the labels listed here.

However, this does not apply to resources created by the Strimzi Operator.

### ⦿ commonAnnotations

All resources created by this chart will include the annotations listed here.

However, this does not apply to resources created by the Strimzi Operator.

### ⦿ strimziConfig

This section contains settings specific to the use of the Strimzi Operator.

It is recommended to refer to the Strimzi documentation for a detailed explanation.

Only the most important parameters are listed here.

| Parameter                                                        | Description                                                      |
|------------------------------------------------------------------|------------------------------------------------------------------|
| [`strimziConfig.useConnectorResources`](#-useconnectorresources) | Adds the corresponding annotation to the `KafkaConnect` resource |
| `strimziConfig.bootstrapServers`                                 | Kafka Broker address                                             |
| `strimziConfig.schemaRegistry`                                   | Schema Registry address (if used)                                |
| [`strimziConfig.metricsConfig`](#-metricsconfig)                 | Parameters for the Prometheus JMX exporter metrics               |
| [`strimziConfig.loggingConfig`](#-loggingconfig)                 | Logging parameters                                               |
| [`strimziConfig.tracingConfig`](#-tracingconfig)                 | Tracing parameters                                               |

#### ‣ useConnectorResources

Refer to the documentation for details:

- [Configuring Kafka Connect connectors](https://strimzi.io/docs/operators/latest/deploying#con-kafka-connector-config-str)
- [Switching to using KafkaConnector custom resources](https://strimzi.io/docs/operators/latest/deploying#con-switching-api-to-kafka-connector-str)

```text
The strimzi.io/use-connector-resources annotation enables KafkaConnectors. If you applied the annotation to your KafkaConnect resource configuration, you need to remove it to use the Kafka Connect API. Otherwise, manual changes made directly using the Kafka Connect REST API are reverted by the Cluster Operator.
```

#### ‣ metricsConfig

| Parameter                                      | Description                                        |
|------------------------------------------------|----------------------------------------------------|
| `metricsConfig.enabled`                        | Enables the JMX exporter for metrics               |
| `metricsConfig.debeziumRules`                  | Activates the original Debezium rules              |
| `metricsConfig.strimziRules`                   | Activates the original Strimzi Kafka Connect rules |
| `metricsConfig.valueFrom.configMapKeyRef.name` | Specifies a ConfigMap containing custom rules      |

#### ‣ loggingConfig

[Refer to the documentation for details](https://strimzi.io/docs/operators/latest/configuring.html#property-kafka-connect-logging-reference)

Defaults:

```yaml
strimziConfig:
  loggingConfig:
    type: inline
    loggers:
      connect.root.logger.level: WARN # [INFO, ERROR, WARN, TRACE, DEBUG, FATAL, OFF]
```

An example of external configuration:

```yaml
strimziConfig:
  loggingConfig:
    type: external
    valueFrom:
      configMapKeyRef:
        name: '{{ tpl .Values.externalConfig.configMap.name $ }}'
        key: loggingConfig
```

#### ‣ tracingConfig

By default, tracing is disabled.

It is recommended to use the `otlp` exporter, even though the image also includes:

- `opentelemetry-exporter-jaeger`
- `opentelemetry-exporter-zipkin`

Additionally, the image includes `opentelemetry-extension-trace-propagators`.

The `values.yaml` file provides examples of possible parameters, so we won’t repeat them here.

However, it is worth noting that all the parameters listed in this section ultimately populate the `deploymentConfig.extraEnv` section.

### ⦿ deploymentConfig

This section contains parameters directly related to the deployment.

If you have a basic understanding of Kubernetes deployments, most settings will not require further explanation.

However, there are certain specifics, so some parameters include links to documentation.

Key specific parameters to note:
- `extraEnv`: Contains Debezium-specific credential configuration, such as `DEBEZIUM_PG_USER` and `DEBEZIUM_PG_PASS` 
- `extraVolumes` and `extraVolumeMounts`: Contain configurations declared in `externalConfig.configMap`

### ⦿ connectConfig

This section contains parameters specific to Kafka Connect.

It is recommended to review the following documentation:
- [Apache Kafka Connect Configs](./HOW-TO-LINKS.md#apache-kafka-connect-documentation)
- [Confluent Kafka Connect](./HOW-TO-LINKS.md#confluent-ocumentation)

However, keep in mind that there are Strimzi Operator limitations. Refer to [Exceptions](https://strimzi.io/docs/operators/latest/configuring#type-KafkaConnectSpec-reference) for details.

### ⦿ connectorConfig

This section contains parameters specific to Kafka Connectors.

Currently, the chart supports only one type of connector — Debezium PostgreSQL.

However, there’s nothing stopping you from adding others as needed. See the example below.

| Parameter                            | Description                                                                                                                   |
|--------------------------------------|-------------------------------------------------------------------------------------------------------------------------------|
| `connectorConfig.common`             | Contains parameters common to all connectors                                                                                  |
| `connectorConfig.common.spec`        | Contains specifications common to all connectors                                                                              |
| `connectorConfig.common.config`      | Contains configuration common to all connectors                                                                               |
| `connectorConfig.debezium`           | Contains parameters common to all Debezium connectors; it has a higher priority than `connectorConfig.common`                 |
| `connectorConfig.debezium.spec`      | Contains specifications common to all Debezium connectors                                                                     |
| `connectorConfig.debezium.config`    | Contains configuration common to all Debezium connectors                                                                      |
| `connectorConfig.debezium.instances` | Contains a list of Debezium connector instances. It includes fields: `name`, `spec` and `config`; it has the highest priority |

Example of declaring an additional MongoDB connector:

```yaml
connectorConfig:
  mongodb:
    spec:
      class: com.mongodb.kafka.connect.MongoSourceConnector
    instances: []
    config:
      connection.host: <database-host-address>
      connection.user: <database-username>
      connection.password: <database-password>
      database: <database-name>
      collection: <database-collection-name>
      ...
```

If needed, create a template similar to `_debezium.tpl` and integrate it into the `kafka-connector.yaml` template.

```yaml
...
  config:
  {{- with merge $instanceConfig $connectorConfig $commonConfig }}
    {{- if eq $kind "debezium" }}
      {{- template "debezium.connector" ( dict "name" $connectorName "mainContext" $ "instanceContext" . ) -}}
    {{- else if eq $kind "mongodb" }}
      {{- template "mongodb.connector" ( dict "name" $connectorName "mainContext" $ "instanceContext" . ) -}}
    {{- else }}
      {{/* insert here some another connector template */}}
    {{- end }}
    {{- tpl ( toYaml . ) $ | nindent 4 }}
  {{- end }}
...
```

### ⦿ externalConfig

This section contains settings related to additional resources created by this chart.

#### ‣ rbac

This section is responsible for generating `Role`/`ClusterRole` and `RoleBinding`/`ClusterRoleBinding` manifests to provide additional privileges to the default service account: `{{ .Values.strimziConfig.connectClusterName }}-connect`

| Parameter      | Description                                 |
|----------------|---------------------------------------------|
| `rbac.enabled` | Enables manifest generation                 |
| `rbac.scope`   | Scope of privileges `[namespaced, cluster]` |
| `rbac.rules`   | List of rules (see the tracing example)     |

#### ‣ podMonitor

This section contains parameters related to integration with monitoring systems.

| Definition                    | Description                                              |
|-------------------------------|----------------------------------------------------------|
| `podMonitor.enabled`          | Enables manifest generation                              |
| `podMonitor.extraLabels`      | Additional labels (may be needed when using an operator) |
| `podMonitor.namespace`        | Namespace where the manifest will be created             |
| `podMonitor.metricsEndpoints` | List of endpoints                                        |


#### ‣ configMap

This section contains settings related to Debezium configuration as well as other settings.

You can add any additional content to this section.

This content will be included in the generated ConfigMap with the corresponding key.

| Parameter                                    | Description                                                                                                                                                       |
|----------------------------------------------|-------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `configMap.enabled`                          | Enables manifest generation                                                                                                                                       |
| `configMap.name`                             | Resource name; used by `deploymentConfig.extraVolumes["external-configuration"]`                                                                                  |
| `configMap.mountPath`                        | Mount path; used by `deploymentConfig.extraVolumeMounts["external-configuration"]`                                                                                |
| `configMap.content`                          | A dictionary of `key: "value"` pairs                                                                                                                              |
| `configMap.content["debezium-bootstrap.sh"]` | Essentially an `entrypoint` for `externalConfig.debeziumConfig.initJob`                                                                                           |
| `configMap.content["psql-root.crt"]`         | If a secure connection to PostgreSQL is required, specify the certificate here and adjust the `database.sslmode` parameter (see an example in `values-test.yaml`) |
| `configMap.content.metricsConfig`            | Overrides the `jmxPrometheusExporter` configuration (also requires modifying the resource name for `strimziConfig.metricsConfig`)                                 |
| `configMap.content.loggingConfig`            | Logging configuration, if you use `strimziConfig.loggingConfig.type: external`                                                                                    |

#### ‣ secret

This section is responsible for generating the Kubernetes Secret manifest.

By default, it contains PostgreSQL credentials intended for Debezium.

You can add any additional content to this section.

It is used for:
- `deploymentConfig.extraEnv["DEBEZIUM_PG_USER"]`
- `deploymentConfig.extraEnv["DEBEZIUM_PG_PASS"]`
- `externalConfig.debeziumConfig.secretName`
- `externalConfig.debeziumConfig.initJob.extraEnv["PGUSER"]`
- `externalConfig.debeziumConfig.initJob.extraEnv["PGPASSWORD"]`

#### ‣ debeziumConfig

This section contains settings that describe the configuration of a Kubernetes job for creating service tables for Debezium.

The primary purpose of this job is to execute commands like the following:

```bash
psql -d <DATABASE_NAME> -c "CREATE SCHEMA IF NOT EXISTS debezium;"
psql -d <DATABASE_NAME> -c "CREATE TABLE IF NOT EXISTS <heartbeat.action.table> (slot_name text, heartbeat_ts timestamp, CONSTRAINT slot_id PRIMARY KEY (slot_name));"
psql -d <DATABASE_NAME> -c "CREATE TABLE IF NOT EXISTS <signal.data.collection> (id VARCHAR(42) PRIMARY KEY, type VARCHAR(32) NOT NULL, data VARCHAR(2048) NULL);"
```

You can find the full list of actions in the generated ConfigMap: `externalConfig.configMap.name`

The `debezium_heartbeat` table is used to send Debezium heartbeats and is created by default.

The `debezium_signal` table is required when using Debezium signals and is created if `connectorConfig.debezium.config["signal.enabled"]` is activated.

#### ‣ extraManifests

This section can contain any other custom Kubernetes manifests (e.g., `ExternalSecret` - see an example in `values-test.yaml`)

---

## Notes

- Everything described here only partially explains the parameters of `connectConfig` and `connectorConfig`. Refer to the official documentation for detailed descriptions.
- Currently, the chart supports and has been tested only with one type of connector: Debezium PostgreSQL.
- By default, it assumes the use of a Schema Registry.
- Kafka Connect automatically creates Kafka topics and schemas if the corresponding table is not empty:

  ```yaml
      topic.creation.enable: true
      auto.register.schemas: true
  ```

- By default, service Kafka topics are named: `{{ .Release.Name }}-connect-cluster-*`
- Although only the `env` provider is used, several are declared (and available): `config.providers: env, file, directory, secrets, configmaps`
- To use `config.providers: secrets, configmaps`, you need to define additional `externalConfig.rbac.rules`.
- By default, three custom groups of Kafka topics are declared: `topic.creation.groups: compacted, deleted, dev`, each with different replication and partition settings.
- A service group of Kafka topics for Debezium is declared by default: `heartbeat`.
- The `heartbeat` group is required for writing Debezium heartbeats and using Debezium signals.
- Default Debezium signals table: `signal.data.collection: debezium.debezium_signal`
- Default Debezium heartbeats table: `heartbeat.action.table: debezium.debezium_heartbeat`
- Default Debezium heartbeats query:

  ```sql
  INSERT INTO debezium.debezium_heartbeat (slot_name, heartbeat_ts) VALUES ('<kafka_connector_name>', NOW()) ON CONFLICT (slot_name) DO UPDATE SET heartbeat_ts = EXCLUDED.heartbeat_ts;
  ```

- In short, the purpose of Debezium heartbeats is to reduce PostgreSQL's `replication slot lag`.
- You do not need to add service tables to the PostgreSQL publication yourself. `debezium_signal` is added automatically by Debezium, and `debezium_heartbeat` does not need it at all.
- Kafka topics produced by Kafka Connect are named: `<(namespace|topic.prefix)>-connect.<database.dbname>.<table.include.list[*]>`
- From the previous point, it follows that table names must be unique within a database, as the schema name does not contribute to the Kafka topic name.
- `namespace` is an alias for `topic.prefix` with higher priority.
- There are two approaches to declaring tables that require replication (the second has a higher priority):

  ① When all produced Kafka topics belong to a single group in `topic.creation.groups`, the `topic.creation.compacted.include` is generated automatically.

    ```yaml
        table.include.list: public.lo, public.li
        topic.creation.group: compacted
    ```

  ② When **not** all produced Kafka topics belong to a single group in `topic.creation.groups`, the `table.include.list` is generated automatically.

    ```yaml
        topic.creation.compacted.include: public.lo, public.li
        topic.creation.deleted.include: public.foo, public.bar
    ```

---

## Special Note on `tracingConfig`

There is an important detail regarding the use of the `opentelemetry` collector in `DaemonSet` mode.

The Strimzi Operator does not support the [Downward API](https://kubernetes.io/docs/concepts/workloads/pods/downward-api/), which means there is no built-in capability to determine the node's IP address.

To address this, the image includes the `kubectl` utility, and the file [kafka_connect_run.sh](https://github.com/strimzi/strimzi-kafka-operator/blob/main/docker-images/kafka-based/kafka/scripts/kafka_connect_run.sh) has been modified.

Original:

```bash
...
if [ "$STRIMZI_TRACING" = "jaeger" ] || [ "$STRIMZI_TRACING" = "opentelemetry" ]; then
    KAFKA_OPTS="$KAFKA_OPTS -javaagent:$(ls "$KAFKA_HOME"/libs/tracing-agent*.jar)=$STRIMZI_TRACING"
    export KAFKA_OPTS
    if [ "$STRIMZI_TRACING" = "opentelemetry" ] && [ -z "$OTEL_TRACES_EXPORTER" ]; then
      # auto-set OTLP exporter
      export OTEL_TRACES_EXPORTER="otlp"
    fi
fi
...
```

Modification:

```bash
...
if [ "$STRIMZI_TRACING" = "opentelemetry" ]; then
    KAFKA_OPTS="$KAFKA_OPTS -javaagent:$(ls "$KAFKA_HOME"/libs/tracing-agent*.jar)=$STRIMZI_TRACING"
    export KAFKA_OPTS
    if [ -n "$OTEL_EXPORTER_OTLP_AGENT_ENDPOINT_TEMPLATE" ] || [ -n "$OTEL_EXPORTER_JAEGER_AGENT_ENDPOINT_TEMPLATE" ]; then
        sleep 5
        K8S_NODE_IP=$(kubectl get pod ${HOSTNAME} -o jsonpath='{.status.hostIP}')
        if [ -n "${K8S_NODE_IP}" ]; then
            echo "K8S_NODE_IP: ${K8S_NODE_IP}"
            export K8S_NODE_IP

            if [ -n "$OTEL_EXPORTER_OTLP_AGENT_ENDPOINT_TEMPLATE" ]; then
                OTEL_EXPORTER_OTLP_AGENT_ENDPOINT=$(envsubst <<< $OTEL_EXPORTER_OTLP_AGENT_ENDPOINT_TEMPLATE)
                echo "OTEL_EXPORTER_OTLP_AGENT_ENDPOINT: ${OTEL_EXPORTER_OTLP_AGENT_ENDPOINT}"
                export OTEL_EXPORTER_OTLP_AGENT_ENDPOINT
                export OTEL_EXPORTER_OTLP_ENDPOINT=${OTEL_EXPORTER_OTLP_AGENT_ENDPOINT}
            fi

            if [ -n "$OTEL_EXPORTER_JAEGER_AGENT_ENDPOINT_TEMPLATE" ]; then
                OTEL_EXPORTER_JAEGER_AGENT_ENDPOINT=$(envsubst <<< $OTEL_EXPORTER_JAEGER_AGENT_ENDPOINT_TEMPLATE)
                echo "OTEL_EXPORTER_JAEGER_AGENT_ENDPOINT: ${OTEL_EXPORTER_JAEGER_AGENT_ENDPOINT}"
                export OTEL_EXPORTER_JAEGER_AGENT_ENDPOINT
                export OTEL_EXPORTER_JAEGER_ENDPOINT=${OTEL_EXPORTER_JAEGER_AGENT_ENDPOINT}
            fi
        fi
    fi
fi
...
```

Thus, when using the `opentelemetry` collector in `DaemonSet` mode, you have to specify the following:

```yaml
  tracingConfig:
    parameters:
      OTEL_EXPORTER_OTLP_AGENT_ENDPOINT_TEMPLATE: http://${K8S_NODE_IP}:4817
```

Additionally, you need to provide extra privileges:

```yaml
externalConfig:
  rbac:
    enabled: true
    rules:
      - apiGroups: [""]
        resources: ["pods", "pods/status"]
        verbs: ["get", "list", "watch"]
```
