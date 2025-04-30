# NOTICE

This file includes notices for third-party components used in this project and their licenses.

## Project Components and Licenses

Copyright © 2025 Dmitry Kadetov (https://github.com/dkadetov/strimzi-kafka-connect). All rights reserved.

This project is based on Apache Kafka Connect, which is part of the Apache Kafka project (Copyright © The Apache Software Foundation).

The Docker image is distributed under the GNU Affero General Public License v3.0 (AGPL-3.0) due to the inclusion of Cloudera Kafka Connect Transformations component.

The Helm chart is distributed under the MIT License.

## Third-Party Components

### Apache License 2.0

The following components are licensed under the Apache License 2.0 (http://www.apache.org/licenses/LICENSE-2.0):

- Apache Kafka Connect (https://kafka.apache.org/documentation/) - Base platform
- Strimzi Kafka Operator (https://github.com/strimzi/strimzi-kafka-operator) - Base Docker image
- Debezium (https://github.com/debezium/debezium) - Core component
- Debezium Connector PostgreSQL (io.debezium:debezium-connector-postgres)
- Debezium Connector Vitess (io.debezium:debezium-connector-vitess)
- Debezium Scripting (io.debezium:debezium-scripting)
- Apache Groovy (org.apache.groovy:groovy)
- Apache Groovy JSR-223 (org.apache.groovy:groovy-jsr223)
- Apache Groovy JSON (org.apache.groovy:groovy-json)
- OpenTelemetry Extension Trace Propagators (io.opentelemetry:opentelemetry-extension-trace-propagators)
- OpenTelemetry Exporter Jaeger (io.opentelemetry:opentelemetry-exporter-jaeger)
- OpenTelemetry Exporter Zipkin (io.opentelemetry:opentelemetry-exporter-zipkin)
- Apicurio Registry Distro Connect Converter (io.apicurio:apicurio-registry-distro-connect-converter)
- Kafka Connect Avro Converter (https://www.confluent.io/hub/confluentinc/kafka-connect-avro-converter)

### Apache License 2.0 with CDDL 1.1

- `kubectl` tool - Licensed under Apache License 2.0, with portions under CDDL 1.1 (https://github.com/kubernetes/kubectl/blob/master/LICENSE)

### GNU Affero General Public License v3.0 (AGPL-3.0)

- Cloudera Kafka Connect Transformations (com.cloudera.dim:kafka-connect:transformations) - Licensed under the GNU Affero General Public License v3.0 (AGPL-3.0)

### Confluent Community License

- Kafka Connect JSON Schema Converter (https://www.confluent.io/hub/confluentinc/kafka-connect-json-schema-converter) - Licensed under the Confluent Community License (https://www.confluent.io/confluent-community-license/)

## Trademark Notices

- Apache, Apache Kafka, Kafka, and related open source project names are trademarks of the Apache Software Foundation.
- Strimzi and related project names are trademarks of their respective owners and the Strimzi project.
- Debezium and related project names are trademarks of Red Hat, Inc.
- Apicurio and related project names are trademarks of Red Hat, Inc.
- Confluent and related product names are trademarks of Confluent, Inc.
- OpenTelemetry and related project names are trademarks of the Cloud Native Computing Foundation.
- Kubernetes, kubectl, and related names are trademarks of The Linux Foundation.
- Cloudera and related product names are trademarks of Cloudera, Inc.

## License Implications for Users

- Using the Helm Chart alone (without the Docker image) is subject only to the MIT License.
- Using the Docker image is subject to the GNU Affero General Public License v3.0 (AGPL-3.0), which requires making the source code available if you distribute the software or provide it as a network service.

## Source Code Availability

In compliance with the GNU Affero General Public License v3.0 (AGPL-3.0), the complete source code for this project, including all components used in the Docker image, is available at: https://github.com/dkadetov/strimzi-kafka-connect

## Additional Information

Complete license texts are available at the following URLs:
- Apache License 2.0: http://www.apache.org/licenses/LICENSE-2.0
- Confluent Community License: https://www.confluent.io/confluent-community-license/
- CDDL 1.1: https://opensource.org/licenses/CDDL-1.1
- GNU Affero General Public License v3.0: https://www.gnu.org/licenses/agpl-3.0.html

This project may include other components not listed above. The absence of a component from this list does not mean it is distributed under a different license than stated in the component's respective files.

## Acknowledgments

This product includes software developed at:
- The Apache Software Foundation (http://www.apache.org/)
- The Strimzi project (https://strimzi.io/)
- The Debezium project (https://debezium.io/)
- The Apicurio project (https://www.apicur.io/)
- The OpenTelemetry project (https://opentelemetry.io/)
- The Kubernetes Authors (https://kubernetes.io/)
- Confluent, Inc. (https://www.confluent.io/)
- Cloudera, Inc. (https://www.cloudera.com/)

## Disclaimer of Warranty and Limitation of Liability

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

Some jurisdictions do not allow the exclusion of implied warranties, so the above exclusion may not apply to you. You may have other rights which vary from jurisdiction to jurisdiction.
