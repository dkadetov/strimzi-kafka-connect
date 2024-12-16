# Brief instructions on how to configure the helm chart

Это на самом деле весьма краткая и поверхностная инструкция по конфигурации.

Она не претендует на полное описание и разъяснение всех возможных параметров.

Предполагается, что вы имеете базовые представления о структуре helm charts и о развертываниях k8s.

Крайне рекомендуется для начала ознакомиться с документацией на:
- [Apache Kafka](https://kafka.apache.org/documentation/#connectconfigs)
- [Confluent Kafka Connect](./HOW-TO-LINKS.md#confluent-ocumentation)
- [Debezium](./HOW-TO-LINKS.md#debezium-ocumentation)
- [Strimzi](./HOW-TO-LINKS.md#strimzi-ocumentation)

Ниже описана структура диаграммы и лишь некоторые особенности.

## Структура helm chart

`clusterOperator` Опциональное включение и настройка дочернего strimzi-kafka-operator chart
`commonLabels` Лейблы, применяемые ко всем ресурсам, создаваемым этой диаграммой
`commonAnnotations` Аннотации, применяемые ко всем ресурсам, создаваемым этой диаграммой
`strimziConfig` Настройки, специфичные при использовании Strimzi Operator
`deploymentConfig` Настройки, относящиеся непосредственно к развертыванию
`connectConfig` Настройки, специфичные для Kafka Connect
`connectorConfig` Настройки, специфичные для Kafka Connector
`externalConfig` Настройки, относящиеся дополнительным ресурсам, создаваемых этой диаграммой

### clusterOperator

Поскольку использование этой диаграммы требует установки Strimzi Cluster Operator, то он содержится в зависимостях в виде дочерней диаграммы.

По умолчанию установка Strimzi Cluster Operator не активирована.

Заметьте, что некоторые настройки изменены относительно исходных и имеют демонстрационный характер.

### commonLabels

Все ресурсы, создаваемые этой диаграммой будут содержать перечисленные здесь лейблы.

Но это не относится к ресурсам, создаваемым Strimzi Operator

### commonAnnotations

Все ресурсы, создаваемые этой диаграммой будут содержать перечисленные здесь аннотации.

Но это не относится к ресурсам, создаваемым Strimzi Operator

### strimziConfig

Секция содержит настройки, специфичные при использовании Strimzi Operator.

Рекомендуется обратиться к документации Strimzi за детальным объяснением.

Здесь лишь приведены наиболее важные параметры.

`strimziConfig.useConnectorResources` Добавляет соответствующую аннотацию к ресурсу `KafkaConnect`
`strimziConfig.bootstrapServers` Адрес Kafka Broker
`strimziConfig.schemaRegistry` Адрес Schema Registry (если используется)
`strimziConfig.metricsConfig` Параметры jmx экспортера Prometheus метрик
`strimziConfig.loggingConfig` Параметры логирования
`strimziConfig.tracingConfig` Параметры трейсинга

#### useConnectorResources

Назначение смотрите в документации:
[Configuring Kafka Connect connectors](https://strimzi.io/docs/operators/latest/deploying#con-kafka-connector-config-str)
[Switching to using KafkaConnector custom resources](https://strimzi.io/docs/operators/latest/deploying#con-switching-api-to-kafka-connector-str)
```text
The strimzi.io/use-connector-resources annotation enables KafkaConnectors. If you applied the annotation to your KafkaConnect resource configuration, you need to remove it to use the Kafka Connect API. Otherwise, manual changes made directly using the Kafka Connect REST API are reverted by the Cluster Operator.
```

#### metricsConfig

`metricsConfig.enabled` включение jmx экспортера метрик
`metricsConfig.debeziumRules` активация оригинальных правил Debezium
`metricsConfig.strimziRules` активация оригинальных правил Strimzi Kafka Connect
`metricsConfig.valueFrom.configMapKeyRef.name` здесь вы можете указать configMap, содержащий кастомные правила

#### tracingConfig

По умолчанию трейсинг выключен.

Рекомендуется использование `otlp` экспортера, несмотря на то, что образ включает также:
- `opentelemetry-exporter-jaeger`
- `opentelemetry-exporter-zipkin`

Также образ содержит `opentelemetry-extension-trace-propagators`

Файл `values.yaml` содержит примеры возможных параметров, не будем повторять их здесь.

Отметим лишь что все перечисленные в этой секции параметры в итоге попадают в секцию `deploymentConfig.extraEnv`

### deploymentConfig

Секция содержит параметры, относящиеся непосредственно к развертыванию.

Если вы имеете базовые представления о развертываниях k8s, то большинство настроек не нуждается в пояснении.

Однако присутствуют некоторые особенности, поэтому некоторые из параметров имеют ссылку на документацию.

Из специфичных параметров необходимо отметить:
- Секция `extraEnv` содержащая специфичную для `debezium` конфигурацию креденшиалов `DEBEZIUM_PG_USER` и `DEBEZIUM_PG_PASS`
- Секции `extraVolumes` и `extraVolumeMounts` содержащие конфигурацию объявленную в `externalConfig.configMap`

### connectConfig

Секция содержит параметры, специфичные для Kafka Connect.

Рекомендуется ознакомиться с документацией:
- [Apache Kafka Connect Configs](https://kafka.apache.org/documentation/#connectconfigs)
- [Confluent Kafka Connect](./HOW-TO-LINKS.md#confluent-ocumentation)

Однако имейте в виду, что есть ограничения Strimzi Operator. Смотрите [Exceptions](https://strimzi.io/docs/operators/latest/configuring#type-KafkaConnectSpec-reference)

### connectorConfig

Секция содержит параметры, специфичные для Kafka Connector.

На данный момент диаграмма поддерживает только один тип коннекторов - Debezium PostgreSQL.

Однако, ничего не мешает добавить другие необходимые вам. Пример смотрите ниже.

connectorConfig.common Секция содержит параметры, являющиеся базовыми для всех коннекторов
connectorConfig.common.spec Секция содержит спецификацию, являющуюся базовой для всех коннекторов
connectorConfig.common.config Секция содержит конфигурацию, являющуюся базовой для всех коннекторов

connectorConfig.debezium Секция содержит параметры, являющиеся базовыми для всех Debezium коннекторов; Имеет более высокий приоритет перед `connectorConfig.common`
connectorConfig.debezium.spec Секция содержит спецификацию, являющуюся базовой для всех Debezium коннекторов
connectorConfig.debezium.config Секция содержит конфигурацию, являющуюся базовой для всех Debezium коннекторов
connectorConfig.debezium.instances Секция содержит список экземпляров Debezium коннекторов; Доступно два поля: `name` и `config`; Имеет наивысший приоритет


Пример объявления дополнительного MongoDB коннектора:

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

При необходимости создайте шаблон по типу `_debezium.tpl` и имплементируйте его в `kafka-connector.yaml` шаблон.


### externalConfig

Секция содержит настройки, относящиеся дополнительным ресурсам, создаваемых этой диаграммой

#### rbac

Секция отвечает за генерацию манифестов `Role/ClusterRole` и `RoleBinding/ClusterRoleBinding` для предоставления дополнительных привилегий дефолтному сервис-аккаунту `{{ .Values.strimziConfig.connectClusterName }}-connect`

rbac.enabled Активация генерации манифеста
rbac.scope Область действия [namespaced, cluster]
rbac.rules Список правил (смотри пример с трейсингом выше)

#### podMonitor

Секция содержит параметры, относящиеся к интеграции с системой мониторинга

podMonitor.enabled Активация генерации манифеста
podMonitor.extraLabels Дополнительные лейблы (могут понадобиться при использовании оператора)
podMonitor.namespace: Неймспейс где будет создан манифест
podMonitor.metricsEndpoints Список эндпойнтов


#### configMap

Секция содержит настройки, относящиеся к конфигурации Debezium, а также некоторые другие.

Вы можете добавить любое другое дополнительное содержание к этой секции.

Этот контент попадет в генерируемый configMap с соответствующим ключом.

configMap.enabled Активация генерации манифеста
configMap.name: Имя ресурса; Используется `deploymentConfig.extraVolumes["external-configuration"]`
configMap.mountPath: Путь монтирования; Используется `deploymentConfig.extraVolumeMounts["external-configuration"]`
configMap.content: Словарь `key: "value"`
configMap.content.debezium-bootstrap.sh Фактически это `entrypoint` для `externalConfig.debeziumConfig.initJob`
configMap.content.psql-root.crt: Если требуется защищенное соединение с PostgreSQL, укажите здесь сертификат, а также измените `database.sslmode` параметр (смотрите пример в `values-test.yaml`) 
configMap.content.metricsConfig: Переопределение `jmxPrometheusExporter` конфигурации (также требуется изменить имя ресурса для `strimziConfig.metricsConfig`)
configMap.content.loggingConfig: Logging config if you use `strimziConfig.loggingConfig.type: external`

#### secret

Секция отвечает за генерацию k8s secret манифеста.

По умолчанию содержит PostgreSQL креденшиалы, предназначенные для Debezium.

Вы можете добавить любое другое дополнительное содержание к этой секции.

Используется для:
- `deploymentConfig.extraEnv["DEBEZIUM_PG_USER"]`
- `deploymentConfig.extraEnv["DEBEZIUM_PG_PASS"]`
- `externalConfig.debeziumConfig.secretName`
- `externalConfig.debeziumConfig.initJob.extraEnv["PGUSER"]`
- `externalConfig.debeziumConfig.initJob.extraEnv["PGPASSWORD"]`

#### debeziumConfig

Секция содержит настройки, описывающие конфигурацию k8s job для создания служебных таблиц Debezium.

Основным предназначением этой job является выполнение подобных команд:

```bash
psql -d <DATABASE_NAME> -c "CREATE TABLE IF NOT EXISTS <heartbeat.action.table> (slot_name text, heartbeat_ts timestamp, CONSTRAINT slot_id PRIMARY KEY (slot_name));"
psql -d <DATABASE_NAME> -c "CREATE TABLE IF NOT EXISTS <signal.data.collection> (id VARCHAR(42) PRIMARY KEY, type VARCHAR(32) NOT NULL, data VARCHAR(2048) NULL);"
```

Полный список действий вы можете найти в генерируемом config-map: `externalConfig.configMap.name`

Таблица `debezium_heartbeat` используется для отправки Debezium heartbeat. Создается по умолчанию.

Таблица `debezium_signal` необходима при использовании Debezium signals. Создается при активированном `connectorConfig.debezium.config["signal.enabled"]`

#### extraManifests

Секция может содержать любые другие пользовательские k8s манифесты (например `ExternalSecret`)


## Особенности

Все описанное здесь лишь частично поясняет параметры `connectConfig` и `connectorConfig`.

Обратитесь к официальной документации за детальным описанием.

- На данный момент диаграмма поддерживает и протестирована только с одним типом коннекторов - Debezium PostgreSQL.
- По умолчанию подразумевается использование Schema Registry
- Kafka Connect самостоятельно создает kafka топики и схемы если соответствующая таблица не пуста:

```yaml
    topic.creation.enable: true
    auto.register.schemas: true
```

- Служебные kafka топики по умолчанию имеют названия: `{{ .Release.Name }}-connect-cluster-*`
- Несмотря на то, что используется только `env` провайдер, объявлены (и доступны) несколько: `config.providers: env, file, directory, secrets, configmaps`
- Для использования `config.providers: secrets, configmaps` вам необходимо определить дополнительные `externalConfig.rbac.rules`
- По умолчанию объявлены 3 пользовательских группы kafka топиков: `topic.creation.groups: compacted, deleted, dev` с разными настройками репликации и партиций
- По умолчанию для Debezium объявлена служебная группа kafka топиков: `heartbeat`
- Группа `heartbeat` необходима для записи Debezium heartbeats и для использования Debezium signals
- Default Debezium signals table: `signal.data.collection: debezium.debezium_signal`
- Default Debezium heartbeats table: `heartbeat.action.table: debezium.debezium_heartbeat`
- Default Debezium heartbeats query:

```sql
INSERT INTO debezium.debezium_heartbeat (slot_name, heartbeat_ts) VALUES ('<kafka_connector_name>', NOW()) ON CONFLICT (slot_name) DO UPDATE SET heartbeat_ts = EXCLUDED.heartbeat_ts;
```

- Если коротко, то назначение Debezium heartbeat заключается в уменьшении PostgreSQL `replication slot lag`
- Продюсируемые Kafka Connect kafka топики имеют названия: `<(namespace|topic.prefix)>-connect.<database.dbname>.<table.include.list[*]>`
- Из предыдущего пункта следует, что имя таблицы должно быть уникальным на уровне базы данных, так как название схемы не участвует в формировании названия kafka топика
- `namespace` является алиасом `topic.prefix` с более высоким приоритетом
- Существует два подхода для объявления таблиц требующих реплицирования (второй имеет более высокий приоритет):
  1. Когда все продюсируемые kafka топики относятся к одной группе `topic.creation.groups`. В этом случае `topic.creation.compacted.include` генерируется автоматически.

    ```yaml
        table.include.list: public.lo, public.li
        topic.creation.group: compacted
    ```

  2. Когда НЕ все продюсируемые kafka топики относятся к одной группе `topic.creation.groups`. В этом случае `table.include.list` генерируется автоматически.

    ```yaml
        topic.creation.compacted.include: public.lo, public.li
        topic.creation.deleted.include: public.foo, public.bar
    ```


Также строит отметить одну важную особенность `tracingConfig`.

Это случай использования `opentelemetry` коллектора в режиме `DaemonSet`.

Strimzi Operator не поддерживает использование Downward API, и поэтому нет встроенной возможности определить IP адрес узла.

Поэтому в образ включена утилита kubectl и изменен файл [kafka_connect_run.sh](https://github.com/strimzi/strimzi-kafka-operator/blob/main/docker-images/kafka-based/kafka/scripts/kafka_connect_run.sh)

Оригинал:

```
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

Модификация:

```
...
if [ "$STRIMZI_TRACING" = "opentelemetry" ]; then
    KAFKA_OPTS="$KAFKA_OPTS -javaagent:$(ls "$KAFKA_HOME"/libs/tracing-agent*.jar)=$STRIMZI_TRACING"
    export KAFKA_OPTS
    if [ -n "$OTEL_EXPORTER_OTLP_AGENT_ENDPOINT" ] || [ -n "$OTEL_EXPORTER_JAEGER_AGENT_ENDPOINT" ]; then
        sleep 15
        K8S_NODE_IP=$(kubectl get pod ${HOSTNAME} -o jsonpath='{.status.hostIP}')
        if [ -n "${K8S_NODE_IP}" ]; then
            echo "K8S_NODE_IP: ${K8S_NODE_IP}"
            export K8S_NODE_IP

            if [ -n "$OTEL_EXPORTER_OTLP_AGENT_ENDPOINT" ]; then
                OTEL_EXPORTER_OTLP_ENDPOINT=$(envsubst <<< $OTEL_EXPORTER_OTLP_AGENT_ENDPOINT)
                echo "OTEL_EXPORTER_OTLP_ENDPOINT: ${OTEL_EXPORTER_OTLP_ENDPOINT}"
                export OTEL_EXPORTER_OTLP_ENDPOINT
            fi

            if [ -n "$OTEL_EXPORTER_JAEGER_AGENT_ENDPOINT" ]; then
                OTEL_EXPORTER_JAEGER_ENDPOINT=$(envsubst <<< OTEL_EXPORTER_JAEGER_ENDPOINT)
                echo "OTEL_EXPORTER_JAEGER_ENDPOINT: ${OTEL_EXPORTER_JAEGER_ENDPOINT}"
                export OTEL_EXPORTER_JAEGER_ENDPOINT
            fi
        fi
    fi
fi
...
```

Таким образом при использовании `opentelemetry` коллектора в режиме `DaemonSet` вам необходимо указать

```yaml
  tracingConfig:
    parameters:
        OTEL_EXPORTER_OTLP_AGENT_ENDPOINT: http://${K8S_NODE_IP}:4817
```

А также предоставить дополнительные привилегии:

```yaml
externalConfig:
  rbac:
    enabled: true
    rules:
      - apiGroups: ["core"]
        resources: ["pods", "pods/status"]
        verbs: ["get", "list", "watch"]
```



Этот проект - попытка реализации декларативного подхода к управлению коннекторами для Apache Kafka Connect.

Strimzi Cluster Operator имеет поддержку многих ресурсов, специфичных для Apache Kafka, среди которых есть `KafkaConnect` и `KafkaConnector`.

Однако, Strimzi не предлагает официальных Helm Charts, упрощающих конфигурирование и развертывание такого рода ресурсов.

Данный Helm Chart создан с целью устранить этот пробел.

На данный момент диаграмма поддерживает и протестирована с одним типом коннекторов - Debezium PostgreSQL Connector.

Однако, ничего не мешает добавить другие необходимые вам.

Крайне рекомендуется для начала ознакомиться с официальной документацией: