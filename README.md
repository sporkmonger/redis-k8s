# redis-k8s
Redis cluster setup for Kubernetes using Debian Jessie.

# Usage

```bash
kubectl create -f redis.yaml
```

# Note

Redis clusters cannot have fewer than 6 nodes. If you set `replicas` to a value lower than 6,
all nodes will stay in master mode and will not join a cluster.
