ARG STRIMZI_VERSION=0.45.0-kafka-3.9.0-amd64
ARG CONFLUENT_VERSION=7.9.0
ARG DEBEZIUM_VERSION=2.7.4
ARG GROOVY_VERSION=4.0.25
ARG CLOUDERA_VERSION=0.0.1.7.3.1.0-197
ARG OTEL_EXT_TRACE_PROPAGATORS_VERSION=1.47.0
ARG OTEL_EXP_JAEGER_VERSION=1.34.1
ARG OTEL_EXP_ZIPKIN_VERSION=1.47.0
ARG KUBECTL_VERSION=1.31.5

# Install confluent avro converter
FROM confluentinc/cp-kafka-connect:${CONFLUENT_VERSION} AS cp

ARG CONFLUENT_VERSION

RUN confluent-hub install --no-prompt confluentinc/kafka-connect-avro-converter:${CONFLUENT_VERSION} && \
    confluent-hub install --no-prompt confluentinc/kafka-connect-json-schema-converter:${CONFLUENT_VERSION} && \
    mkdir -p /tmp/kafka/plugins/avro-converter /tmp/kafka/plugins/json-schema-converter && \
    cp -a /usr/share/confluent-hub-components/confluentinc-kafka-connect-avro-converter/lib/. /tmp/kafka/plugins/avro-converter/ && \
    cp -a /usr/share/confluent-hub-components/confluentinc-kafka-connect-json-schema-converter/lib/. /tmp/kafka/plugins/json-schema-converter/;

FROM quay.io/strimzi/kafka:${STRIMZI_VERSION}

ARG DEBEZIUM_VERSION
ARG GROOVY_VERSION
ARG CLOUDERA_VERSION
ARG OTEL_EXT_TRACE_PROPAGATORS_VERSION
ARG OTEL_EXP_JAEGER_VERSION
ARG OTEL_EXP_ZIPKIN_VERSION
ARG KUBECTL_VERSION

USER root:root

RUN mkdir -p /tmp/debezium /opt/kafka/plugins/debezium && \
    chmod 755 /opt/kafka/plugins/debezium; \
    # Fetch debezium-connector-postgres artifact
    curl -L https://repo1.maven.org/maven2/io/debezium/debezium-connector-postgres/${DEBEZIUM_VERSION}.Final/debezium-connector-postgres-${DEBEZIUM_VERSION}.Final-plugin.tar.gz \
         -o /tmp/debezium/debezium-connector-postgres.tar.gz && \
    tar -zxf /tmp/debezium/debezium-connector-postgres.tar.gz -C /tmp/debezium && \
    cp -a /tmp/debezium/debezium-connector-postgres/* /opt/kafka/plugins/debezium/ && \
    # Fetch debezium-scripting artifact
    curl -L https://repo1.maven.org/maven2/io/debezium/debezium-scripting/${DEBEZIUM_VERSION}.Final/debezium-scripting-${DEBEZIUM_VERSION}.Final.tar.gz \
         -o /tmp/debezium/debezium-scripting.tar.gz && \
    tar -zxf /tmp/debezium/debezium-scripting.tar.gz -C /tmp/debezium && \
    cp -a /tmp/debezium/debezium-scripting/* /opt/kafka/plugins/debezium/ && \
    chmod 644 /opt/kafka/plugins/debezium/* && \
    rm -rf /tmp/debezium; \
    # Fetch groovy artifacts (required by the debezium-scripting plug-in)
    curl -L https://repo1.maven.org/maven2/org/apache/groovy/groovy/${GROOVY_VERSION}/groovy-${GROOVY_VERSION}.jar \
         -o /opt/kafka/libs/groovy-${GROOVY_VERSION}.jar && \
    curl -L https://repo1.maven.org/maven2/org/apache/groovy/groovy-jsr223/${GROOVY_VERSION}/groovy-jsr223-${GROOVY_VERSION}.jar \
         -o /opt/kafka/libs/groovy-jsr223-${GROOVY_VERSION}.jar && \
    curl -L https://repo1.maven.org/maven2/org/apache/groovy/groovy-json/${GROOVY_VERSION}/groovy-json-${GROOVY_VERSION}.jar \
         -o /opt/kafka/libs/groovy-json-${GROOVY_VERSION}.jar && \
    chmod 644 /opt/kafka/libs/groovy-*.jar; \
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
    # Fetch cloudera artifacts \
    mkdir /opt/kafka/plugins/cloudera && \
    chmod 755 /opt/kafka/plugins/cloudera; \
    curl -L https://repository.cloudera.com/repository/libs-release-local/com/cloudera/dim/kafka-connect/transformations/${CLOUDERA_VERSION}/transformations-${CLOUDERA_VERSION}-jar-with-dependencies.jar \
         -o /opt/kafka/plugins/cloudera/transformations-jar-with-dependencies.jar; \
    chmod 644 /opt/kafka/plugins/cloudera/*; \
    # Add kubectl
    curl -L https://dl.k8s.io/release/v${KUBECTL_VERSION}/bin/linux/amd64/kubectl \
         -o /bin/kubectl && \
    chmod 755 /bin/kubectl;

# Copy Confluent packages from previous stage
COPY --from=cp /tmp/kafka/plugins /opt/kafka/plugins/

# Override to implement OTEL_EXPORTER_OTLP_AGENT_ENDPOINT support
COPY --chmod=755 scripts/kafka_connect_run.sh /opt/kafka/

# Grant ownership to 1001 user
RUN chown -R 1001:1001 /opt/kafka/plugins;

USER 1001
