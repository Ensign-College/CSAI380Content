# 5.4 Scaling Skill Practice — Teacher Notes

Verified 2026-10-15 against GKE Autopilot cluster (us-central1) in an instructor test project.

## Solutions

### Lag experiment (measured results)

```bash
kubectl exec kafka-controller-0 -n <ns> -- kafka-consumer-groups.sh \
  --bootstrap-server localhost:9092 --describe --group logging-sink
```

| Phase | Observed |
| --- | --- |
| Baseline, 1 replica | LAG 0 on all 3 partitions; one consumer ID owns all partitions |
| Consumer scaled to 0 + 200 events produced | LAG 200 accumulated (no consumer, log-end offset keeps growing) |
| Scaled to 3 replicas | Three distinct consumer IDs, one partition each; lag drained to 0 within ~30s |

Partitions-vs-consumers answer: with 3 partitions, a 4th and 5th consumer in the same group sit **idle** — partitions are the parallelism ceiling.

### HPA (measured results)

```bash
kubectl apply -f k8s/hpa.yaml            # after namespace sed
./scripts/load-generator.sh <ns> practice-events 150000
kubectl get hpa consumer-hpa -n <ns> --watch
```

Observed: CPU rose from 7% → **71% against the 60% target**, HPA scaled the consumer 3 → **4 replicas** (max), then CPU fell to ~13% as the backlog drained. Capacity-vs-responsibility: tripled consumers triple the write pressure on whatever sits downstream (MySQL sink, logs, quotas).

## Gotchas

| Symptom | Cause | Fix |
| --- | --- | --- |
| HPA shows `<unknown>/60%` | Target pods lack CPU requests | Starter logging-consumer sets requests; HPA needs them |
| HPA doesn't scale for ~1 min | Metrics window + stabilization delay | Expected; watch for 2–3 minutes |
| Extra consumers never get partitions | More consumers than partitions | Expected — teach it, don't fix it |
| Load generator pod name wrong | Chart names the broker pod `kafka-controller-0` | Script already targets it; adjust if release name differs |

## Verification status

All steps executed: baseline lag, consumer-stop lag accumulation, 3-replica redistribution, HPA scale-up under load, and scale-down pressure after drain.
