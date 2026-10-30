# 4.4 Kafka Skill Practice — Teacher Notes

Verified 2026-10-15 against GKE Autopilot cluster (us-central1) in an instructor test project.

## Solutions

```bash
helm repo add bitnami https://charts.bitnami.com/bitnami
helm install kafka bitnami/kafka -n <ns> -f helm/kafka-values.yaml

# topic
kubectl exec kafka-controller-0 -n <ns> -- kafka-topics.sh --create --topic practice-events \
  --bootstrap-server localhost:9092 --partitions 3 --replication-factor 1

# produce
kubectl exec -i kafka-controller-0 -n <ns> -- sh -c \
  'printf "event-one\nevent-two\nevent-three\n" | kafka-console-producer.sh --bootstrap-server localhost:9092 --topic practice-events'

# consume (verified output: 3 messages)
kubectl exec kafka-controller-0 -n <ns> -- kafka-console-consumer.sh \
  --bootstrap-server localhost:9092 --topic practice-events --from-beginning --max-messages 3 --timeout-ms 60000

# logging sink
kubectl apply -f k8s/kafka/logging-consumer.yaml   # after namespace sed
kubectl logs deploy/logging-consumer -n <ns> -f    # events appear here
```

Partitioning answer: ordering is guaranteed only within a partition; messages without keys round-robin across partitions, so global ordering is not guaranteed. Classification: this is **streaming** (events consumed continuously as they arrive, not accumulated into scheduled batches).

## Gotchas

| Symptom | Cause | Fix |
| --- | --- | --- |
| `docker.io/bitnami/kafka:<tag>: not found` (ImagePullBackOff) | Bitnami deleted legacy tags from Docker Hub in 2025 | `image.repository: bitnamilegacy/kafka` + `global.security.allowInsecureImages: true` (in starter values); same fix for the logging-consumer image |
| Producer succeeds but consumer times out with 0 messages | Single broker can't create `__consumer_offsets` (default replication factor 3), so consumer groups never form | `overrideConfiguration` with `offsets.topic.replication.factor: 1` etc. (in starter values) — note the chart key is `overrideConfiguration`, NOT `extraConfig` |
| `error: unable to upgrade connection: container not found` | exec raced the pod during a config-change rolling restart | `kubectl rollout status statefulset/kafka-controller` before exec'ing |
| Consumer output hidden by `Defaulted container` notice | Pod has an init container | Harmless; filter with `grep -v Defaulted` |
| PVC provisions at 8Gi no matter what `persistence.size` says | KRaft chart ignores top-level `persistence:`; sizing lives per-role | Set `controller.persistence.size` (in starter values); also note PVC size is immutable — resizing requires delete + reinstall |

## Verification status

All steps executed: Helm install, topic creation, console round-trip (3/3 messages), and logging sink receiving produced events. Re-tested 2026-10-15 after moving PVC sizing to `controller.persistence.size: 2Gi`; verified the PVC provisions at 2Gi and the full produce→consume→sink path works on it.
