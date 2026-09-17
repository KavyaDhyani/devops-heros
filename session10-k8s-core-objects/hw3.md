## 1. Differences Between StatefulSet, Deployment, and DaemonSet

| Architectural Dimension | Deployment | StatefulSet | DaemonSet |
| :--- | :--- | :--- | :--- |
| **Primary Design Purpose** | Manages stateless, interchangeable workloads requiring automated rollout and scaling strategies. | Manages stateful applications requiring unique network identities, ordered execution, and persistent storage. | Ensures that all (or a designated subset of) cluster nodes run exactly one copy of a Pod. |
| **Pod Identity & Naming** | Dynamic and non-deterministic (e.g., `web-deployment-7f98b6988f-k2m9x`). Pods are completely interchangeable. | Deterministic, sequential, and sticky (e.g., `db-statefulset-0`, `db-statefulset-1`). Indices are preserved across restarts. | Node-bound with random hash suffixes (e.g., `fluentd-ds-g7x4q`). Exactly one pod runs per targeted node. |
| **Lifecycle & Ordering** | Unordered. Pods can be provisioned, updated, and terminated concurrently according to rolling update quotas (`maxSurge`, `maxUnavailable`). | Strictly ordered. Scaled up monotonically from index `0` to `N-1`. Scaled down or terminated in reverse order (`N-1` to `0`). | Parallel or sequential provisioning triggered automatically upon node discovery, node joining, or node taint clearance. |
| **Storage Architecture** | Typically shares a single volume (e.g., `ReadWriteMany` NFS) or operates on ephemeral storage (`emptyDir`). | Employs `volumeClaimTemplates` to automatically provision a dedicated, permanent `PersistentVolumeClaim` (PVC) for every individual pod index. | Mounts host filesystem paths directly via `hostPath`, or accesses node-local storage. |
| **Network & Discovery** | Routes traffic across pods via standard Kubernetes Services (Round-Robin/IPTables/IPVS). | Requires a Headless Service (`clusterIP: None`) to establish predictable SRV and A-records per pod for inter-node clustering. | Accesses network interfaces typically via standard services, `hostPort`, or `hostNetwork: true`. |
| **Standard Enterprise Workloads** | Web servers, stateless REST APIs, frontend interfaces, worker queue processors. | Distributed databases (PostgreSQL clusters, Cassandra), message brokers (Apache Kafka, RabbitMQ), distributed state engines (etcd, ZooKeeper). | Node-level monitoring agents (Prometheus `node-exporter`), log collectors (Fluentd, Vector), network plugins (Calico, Cilium, kube-proxy). |

---

## 2. Differences Between ReplicaSet and Deployment

A **ReplicaSet** and a **Deployment** are closely related resources within the `apps/v1` API group, but they operate at different levels of abstraction in the Kubernetes control plane.

### Core Architectural Distinction
* A **ReplicaSet** is a low-level reconciliation controller responsible solely for maintaining a specified number of identical Pod replicas running at all times using label selectors.
* A **Deployment** is a higher-level orchestrator that manages ReplicaSets declaratively. It provides automated lifecycle capabilities, including versioning, canary releases, rolling updates, and rollbacks.

## Screenshots

### Rolling Update

![Screenshot 4](screenshots/Screenshot%202026-09-17%20220359.png)

![Screenshot 3](screenshots/Screenshot%202026-09-17%20220112.png)

### Blue-Green

![Screenshot 6](screenshots/Screenshot%202026-09-17%20220732.png)



![Screenshot 5](screenshots/Screenshot%202026-09-17%20220658.png)


![Screenshot 8](screenshots/Screenshot%202026-09-17%20220901.png)

![Screenshot 7](screenshots/Screenshot%202026-09-17%20220804.png)


### Canary
![Screenshot 9](screenshots/Screenshot%202026-09-17%20221856.png)

![Screenshot 10](screenshots/Screenshot%202026-09-17%20221907.png)

![Screenshot 11](screenshots/Screenshot%202026-09-17%20221935.png)

![Screenshot 12](screenshots/Screenshot%202026-09-17%20221948.png)

![Screenshot 13](screenshots/Screenshot%202026-09-17%20221959.png)

![Screenshot 14](screenshots/Screenshot%202026-09-17%20222010.png)

### Recreate

![Screenshot 15](screenshots/Screenshot%202026-09-17%20223046.png)

![Screenshot 16](screenshots/Screenshot%202026-09-17%20223100.png)

![Screenshot 17](screenshots/Screenshot%202026-09-17%20223111.png)



# Fully Qualified Domain Name (FQDN) & CoreDNS in Kubernetes

This technical reference explains cluster DNS resolution, the role of **CoreDNS**, and the structural anatomy of **Fully Qualified Domain Names (FQDNs)** for Services and Pods in Kubernetes.

---

## 1. Overview: Service Discovery in Kubernetes

In Kubernetes, Pod IPs are ephemeral—they change whenever a Pod restarts, reschedules, or scales. To provide reliable networking between services without hardcoding changing IP addresses, Kubernetes implements a built-in internal DNS service (implemented by default via **CoreDNS**).

Every Service and Pod registered in the cluster receives an internal DNS record that can be addressed via an FQDN.

---

## 2. Anatomy of a Kubernetes FQDN

A Fully Qualified Domain Name (FQDN) is an unambiguous domain name that specifies its exact location in the DNS hierarchy down to the root domain. In Kubernetes, the default cluster root domain is `cluster.local`.

### A. Standard Service FQDN
For standard ClusterIP, NodePort, and LoadBalancer services:

$$\text{<service-name>}.\text{<namespace>}.\text{svc}.\text{<cluster-domain>}$$

* **`<service-name>`**: Name of the Kubernetes Service object.
* **`<namespace>`**: Kubernetes namespace where the Service resides.
* **`svc`**: Indicates the resource type is a Service.
* **`<cluster-domain>`**: The cluster base domain (default: `cluster.local`).

**Example:**
```text
frontend-svc.production.svc.cluster.local
