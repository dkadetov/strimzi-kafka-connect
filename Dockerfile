ARG STRIMZI_VERSION=0.45.0-kafka-3.9.0-amd64
ARG CONFLUENT_VERSION=7.8.0
ARG DEBEZIUM_VERSION=2.7.4
ARG CONNECT_TRANSFORM_VERSION=1.6.1
ARG CONNECT_JSON_SCHEMA_CONVERTER_VERSION=7.8.0
ARG OTEL_EXT_TRACE_PROPAGATORS_VERSION=1.46.0
ARG OTEL_EXP_JAEGER_VERSION=1.34.1
ARG OTEL_EXP_ZIPKIN_VERSION=1.46.0
ARG KUBECTL_VERSION=1.31.5

# Install confluent avro converter & debezium connector
FROM confluentinc/cp-kafka-connect:${CONFLUENT_VERSION} as cp

ARG CONFLUENT_VERSION
ARG CONNECT_TRANSFORM_VERSION
ARG CONNECT_JSON_SCHEMA_CONVERTER_VERSION

RUN confluent-hub install --no-prompt confluentinc/kafka-connect-avro-converter:${CONFLUENT_VERSION} && \
    confluent-hub install --no-prompt confluentinc/kafka-connect-json-schema-converter:${CONNECT_JSON_SCHEMA_CONVERTER_VERSION} && \
    confluent-hub install --no-prompt confluentinc/connect-transforms:${CONNECT_TRANSFORM_VERSION} && \
    mkdir -p /tmp/kafka/plugins/avro /tmp/kafka/plugins/json-schema-converter /tmp/kafka/plugins/transforms && \
    cp -a /usr/share/confluent-hub-components/confluentinc-kafka-connect-avro-converter/lib/. /tmp/kafka/plugins/avro/ && \
    cp -a /usr/share/confluent-hub-components/confluentinc-kafka-connect-json-schema-converter/lib/. /tmp/kafka/plugins/json-schema-converter/ && \
    cp -a /usr/share/confluent-hub-components/confluentinc-connect-transforms/lib/. /tmp/kafka/plugins/transforms/;

# Copy privious artifacts to the main strimzi kafka image
FROM quay.io/strimzi/kafka:${STRIMZI_VERSION}

ARG DEBEZIUM_VERSION
ARG OTEL_EXT_TRACE_PROPAGATORS_VERSION
ARG OTEL_EXP_JAEGER_VERSION
ARG OTEL_EXP_ZIPKIN_VERSION
ARG KUBECTL_VERSION

USER root:root

RUN mkdir -p /tmp/debezium /opt/kafka/plugins/debezium; \
    # Fetch debezium-connector-postgres artifact
    curl -L https://repo1.maven.org/maven2/io/debezium/debezium-connector-postgres/${DEBEZIUM_VERSION}.Final/debezium-connector-postgres-${DEBEZIUM_VERSION}.Final-plugin.tar.gz \
         -o /tmp/debezium/debezium-connector-postgres.tar.gz && \
    tar -zxf /tmp/debezium/debezium-connector-postgres.tar.gz -C /tmp/debezium && \
    cp -a /tmp/debezium/debezium-connector-postgres/. /opt/kafka/plugins/debezium/ && \
    chmod -R 644 /opt/kafka/plugins/debezium && \
    rm -rf /tmp/debezium; \
    # Fetch opentelemetry-extension-trace-propagators artifact
    curl -L https://repo1.maven.org/maven2/io/opentelemetry/opentelemetry-extension-trace-propagators/${OTEL_EXT_TRACE_PROPAGATORS_VERSION}/opentelemetry-extension-trace-propagators-${OTEL_EXT_TRACE_PROPAGATORS_VERSION}.jar \
         -o /opt/kafka/libs/opentelemetry-extension-trace-propagators-${OTEL_EXT_TRACE_PROPAGATORS_VERSION}.jar && \
    chmod 644 /opt/kafka/libs/opentelemetry-extension-trace-propagators-${OTEL_EXT_TRACE_PROPAGATORS_VERSION}.jar; \
    # Fetch opentelemetry-exporter-jaeger artifact
    curl -L https://repo1.maven.org/maven2/io/opentelemetry/opentelemetry-exporter-jaeger/${OTEL_EXP_JAEGER_VERSION}/opentelemetry-exporter-jaeger-${OTEL_EXP_JAEGER_VERSION}.jar \
         -o /opt/kafka/libs/opentelemetry-exporter-jaeger-${OTEL_EXP_JAEGER_VERSION}.jar && \
    chmod 644 /opt/kafka/libs/opentelemetry-exporter-jaeger-${OTEL_EXP_JAEGER_VERSION}.jar; \
    # Fetch opentelemetry-exporter-zipkin artifact
    curl -L https://repo1.maven.org/maven2/io/opentelemetry/opentelemetry-exporter-zipkin/${OTEL_EXP_ZIPKIN_VERSION}/opentelemetry-exporter-zipkin-${OTEL_EXP_ZIPKIN_VERSION}.jar \
         -o /opt/kafka/libs/opentelemetry-exporter-zipkin-${OTEL_EXP_ZIPKIN_VERSION}.jar && \
    chmod 644 /opt/kafka/libs/opentelemetry-exporter-zipkin-${OTEL_EXP_ZIPKIN_VERSION}.jar; \
    # Add kubectl
    curl -L https://dl.k8s.io/release/v${KUBECTL_VERSION}/bin/linux/amd64/kubectl \
         -o /bin/kubectl && \
    chmod 755 /bin/kubectl;

# Copy Confluent packages from previous stage
COPY --from=cp /tmp/kafka/plugins /opt/kafka/plugins/

# Override to implement OTEL_EXPORTER_OTLP_AGENT_ENDPOINT support
COPY --chmod=755 scripts/kafka_connect_run.sh /opt/kafka/

USER 1001
