ARG STRIMZI_VERSION=0.45.0-kafka-3.9.0-amd64
ARG CONFLUENT_VERSION=7.9.0
ARG DEBEZIUM_VERSION=2.7.4
ARG GROOVY_VERSION=4.0.25
ARG CLOUDERA_VERSION=0.0.1.7.3.1.100-57
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

FROM busybox:1.37.0 AS collector

ARG DEBEZIUM_VERSION
ARG GROOVY_VERSION
ARG CLOUDERA_VERSION
ARG OTEL_EXT_TRACE_PROPAGATORS_VERSION
ARG OTEL_EXP_JAEGER_VERSION
ARG OTEL_EXP_ZIPKIN_VERSION

COPY --from=cp /tmp/kafka/plugins/ /tmp/plugins/

# Fetch debezium-connector-postgres artifact
RUN mkdir -p /tmp/debezium /tmp/plugins/debezium && \
    wget -O /tmp/debezium/debezium-connector-postgres.tar.gz https://repo1.maven.org/maven2/io/debezium/debezium-connector-postgres/${DEBEZIUM_VERSION}.Final/debezium-connector-postgres-${DEBEZIUM_VERSION}.Final-plugin.tar.gz && \
    tar -zxf /tmp/debezium/debezium-connector-postgres.tar.gz -C /tmp/debezium && \
    cp -a /tmp/debezium/debezium-connector-postgres/* /tmp/plugins/debezium/;

# Fetch debezium-scripting artifact
RUN wget -O /tmp/debezium/debezium-scripting.tar.gz https://repo1.maven.org/maven2/io/debezium/debezium-scripting/${DEBEZIUM_VERSION}.Final/debezium-scripting-${DEBEZIUM_VERSION}.Final.tar.gz && \
    tar -zxf /tmp/debezium/debezium-scripting.tar.gz -C /tmp/debezium && \
    cp -a /tmp/debezium/debezium-scripting/* /tmp/plugins/debezium/ && \
    chmod 644 /tmp/plugins/debezium/* && \
    rm -rf /tmp/debezium;

# Fetch groovy artifacts (required by the debezium-scripting plug-in)
RUN mkdir -p /tmp/libs && \
    wget -O /tmp/libs/groovy-${GROOVY_VERSION}.jar        https://repo1.maven.org/maven2/org/apache/groovy/groovy/${GROOVY_VERSION}/groovy-${GROOVY_VERSION}.jar && \
    wget -O /tmp/libs/groovy-jsr223-${GROOVY_VERSION}.jar https://repo1.maven.org/maven2/org/apache/groovy/groovy-jsr223/${GROOVY_VERSION}/groovy-jsr223-${GROOVY_VERSION}.jar && \
    wget -O /tmp/libs/groovy-json-${GROOVY_VERSION}.jar   https://repo1.maven.org/maven2/org/apache/groovy/groovy-json/${GROOVY_VERSION}/groovy-json-${GROOVY_VERSION}.jar && \
    chmod 644 /tmp/libs/groovy-*.jar;

# Fetch opentelemetry-extension-trace-propagators artifact
RUN wget -O /tmp/libs/opentelemetry-extension-trace-propagators-${OTEL_EXT_TRACE_PROPAGATORS_VERSION}.jar https://repo1.maven.org/maven2/io/opentelemetry/opentelemetry-extension-trace-propagators/${OTEL_EXT_TRACE_PROPAGATORS_VERSION}/opentelemetry-extension-trace-propagators-${OTEL_EXT_TRACE_PROPAGATORS_VERSION}.jar && \
    chmod 644 /tmp/libs/opentelemetry-extension-trace-propagators-${OTEL_EXT_TRACE_PROPAGATORS_VERSION}.jar;

# Fetch opentelemetry-exporter-jaeger artifact
RUN wget -O /tmp/libs/opentelemetry-exporter-jaeger-${OTEL_EXP_JAEGER_VERSION}.jar https://repo1.maven.org/maven2/io/opentelemetry/opentelemetry-exporter-jaeger/${OTEL_EXP_JAEGER_VERSION}/opentelemetry-exporter-jaeger-${OTEL_EXP_JAEGER_VERSION}.jar && \
    chmod 644 /tmp/libs/opentelemetry-exporter-jaeger-${OTEL_EXP_JAEGER_VERSION}.jar;

# Fetch opentelemetry-exporter-zipkin artifact
RUN wget -O /tmp/libs/opentelemetry-exporter-zipkin-${OTEL_EXP_ZIPKIN_VERSION}.jar https://repo1.maven.org/maven2/io/opentelemetry/opentelemetry-exporter-zipkin/${OTEL_EXP_ZIPKIN_VERSION}/opentelemetry-exporter-zipkin-${OTEL_EXP_ZIPKIN_VERSION}.jar && \
    chmod 644 /tmp/libs/opentelemetry-exporter-zipkin-${OTEL_EXP_ZIPKIN_VERSION}.jar;

# Fetch cloudera artifacts
RUN mkdir -p /tmp/plugins/cloudera && \
    wget -O /tmp/plugins/cloudera/transformations-jar-with-dependencies.jar https://repository.cloudera.com/repository/libs-release-local/com/cloudera/dim/kafka-connect/transformations/${CLOUDERA_VERSION}/transformations-${CLOUDERA_VERSION}-jar-with-dependencies.jar && \
    chmod 644 /tmp/plugins/cloudera/*;

FROM quay.io/strimzi/kafka:${STRIMZI_VERSION} AS target

ARG KUBECTL_VERSION

USER root:root

COPY --from=collector /tmp/plugins/ /opt/kafka/plugins/

COPY --from=collector /tmp/libs/ /opt/kafka/libs/

# Override to implement OTEL_EXPORTER_OTLP_AGENT_ENDPOINT support
COPY --chmod=755 scripts/kafka_connect_run.sh /opt/kafka/

# Grant permissions to 1001 user & Add kubectl
RUN chown -R 1001:1001 /opt/kafka/plugins; \
    mkdir -p /opt/kafka/ext_classpath/avro-converter && \
    ln -s /opt/kafka/plugins/avro-converter/*-${CONFLUENT_VERSION}.jar /opt/kafka/ext_classpath/avro-converter/; \
    ln -s /opt/kafka/plugins/avro-converter/avro-*.jar /opt/kafka/ext_classpath/avro-converter/; \
    ln -s /opt/kafka/plugins/avro-converter/checker-qual-*.jar /opt/kafka/ext_classpath/avro-converter/; \
    ln -s /opt/kafka/plugins/avro-converter/commons-codec-*.jar /opt/kafka/ext_classpath/avro-converter/; \
    ln -s /opt/kafka/plugins/avro-converter/commons-compress-*.jar /opt/kafka/ext_classpath/avro-converter/; \
    ln -s /opt/kafka/plugins/avro-converter/logredactor-*.jar /opt/kafka/ext_classpath/avro-converter/; \
    ln -s /opt/kafka/plugins/avro-converter/logredactor-metrics-*.jar /opt/kafka/ext_classpath/avro-converter/; \
    ln -s /opt/kafka/plugins/avro-converter/minimal-json-*.jar /opt/kafka/ext_classpath/avro-converter/; \
    ln -s /opt/kafka/plugins/avro-converter/re2j-*.jar /opt/kafka/ext_classpath/avro-converter/; \
    # Add kubectl
    curl -L https://dl.k8s.io/release/v${KUBECTL_VERSION}/bin/linux/amd64/kubectl \
         -o /bin/kubectl && \
    chmod 755 /bin/kubectl;

# Export confluent-avro-converter for cloudera
ENV CLASSPATH=/opt/kafka/ext_classpath/avro-converter/*

USER 1001
