
# Brief instructions on how to install the Helm Chart

**Table of Contents**
- [Installing Strimzi Cluster Operator](#installing-strimzi-cluster-operator)
- [Installing Apache Kafka Connect by Strimzi](#installing-apache-kafka-connect-by-strimzi)
  - [Quick Installation](#quick-installation)
  - [Advanced Installation Approach](#advanced-installation-approach)
  - [Uninstalling the Chart](#uninstalling-the-chart)


## Installing Strimzi Cluster Operator

[Official Installation Documentation.](https://github.com/strimzi/strimzi-kafka-operator/blob/main/helm-charts/helm3/strimzi-kafka-operator/README.md)

If you have not yet installed the Strimzi Cluster Operator, you need to install it first.

It is also recommended to update it to the same version as the base Strimzi Kafka image (refer to the [Dockerfile](/Dockerfile)).

For this purpose, you can use the `strimzi-kafka-operator` sub-chart. See the [instruction on how to configure.](/docs/HOW-TO-CONFIGURE.md#cluster-operator)

However, keep in mind that Helm does not manage the lifecycle of Kubernetes CRDs. See more in the Helm [documentation.](https://helm.sh/docs/chart_best_practices/custom_resource_definitions/#some-caveats-and-explanations)

Thus, when upgrading or, in some cases, during installation, it is recommended to manually install Strimzi CRDs **beforehand**.

```bash
# Download the `strimzi-kafka-operator` Helm chart
helm pull oci://quay.io/strimzi-helm/strimzi-kafka-operator --version 0.45.0

# Extract the Helm chart
tar --extract --file=strimzi-kafka-operator-0.45.0.tgz

# Install Strimzi CRDs
kubectl apply --server-side --filename ./strimzi-kafka-operator/crds --recursive --namespace strimzi
```

Now, you can safely install or upgrade the Strimzi Cluster Operator, as well as the `strimzi-kafka-connect` Helm chart.


## Installing Apache Kafka Connect by Strimzi

### Quick Installation

```bash
helm install <release-name> oci://ghcr.io/dkadetov/strimzi-kafka-connect --version 1.0.2 --values <customized-values-file> --namespace strimzi
```

### Advanced Installation Approach

Download the latest stable version of the Helm chart.

```bash
helm pull oci://ghcr.io/dkadetov/strimzi-kafka-connect --version 1.0.2
```

To preview generated sample manifests, you can use [values-test.yaml](/helm/values-test.yaml) for rendering.

```bash
helm template strimzi-kafka-connect-1.0.2.tgz --values values-test.yaml
```

Create a configuration file with the necessary settings and check the rendered output.

```bash
helm template strimzi-kafka-connect-1.0.2.tgz --values values-custom.yaml
```

Install the chart (for example, in the `strimzi` namespace).

```bash
helm upgrade <release-name> strimzi-kafka-connect-1.0.2.tgz --values values-custom.yaml --install --namespace strimzi
```

### Uninstalling the Chart

```bash
helm uninstall <release-name> --namespace strimzi
```
