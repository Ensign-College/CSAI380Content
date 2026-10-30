# CSAI 380: AI Operations — Skill Practice Assignments

Prototype weekly Skill Practice assignments for CSAI 380 (AI infrastructure on GKE/GCP, with Terraform and GitHub Actions).

Exercises are only marked ✅ VERIFIED after every step has been executed against a real GKE/GCP environment — see [AGENTS.md](AGENTS.md). Student-facing starter files live in [starter/](starter/), mirroring the student repository layout.

## Table of Contents

| Week | Assignment | Topic | Starter repo | Status |
| ---- | ---------- | ----- | ------------ | ------ |
| 1 | [1.4 Build, Deploy, and Explore](1.4-build-deploy-explore.md) | Docker image lifecycle, GKE deployments and services, Terraform intro, GitHub Actions build/push | [CSAI380-build-deploy-starter](https://github.com/Ensign-College/CSAI380-build-deploy-starter) | 🚧 DRAFT¹ |
| 1 | [1.5 Block Project: Collecting the Data](https://github.com/Ensign-College/CSAI380FinalProject/blob/main/1.5-collecting-the-data.md) | Containerize and deploy STEDI to GKE, Terraform namespace/registry, GitHub Actions build/push, architecture v1 | [CSAI380FinalProject](https://github.com/Ensign-College/CSAI380FinalProject) | 🚧 DRAFT² |
| 2 | [2.4 Stateful Services: The Persistence Experiment](2.4-stateful-persistence-practice.md) | Redis/MySQL, PVs, PVCs, StorageClasses, StatefulSets, Secrets | [CSAI380-stateful-persistence-starter](https://github.com/Ensign-College/CSAI380-stateful-persistence-starter) | ✅ VERIFIED 2026-10-15 |
| 2 | [2.5 Block Project: Saving the Data](https://github.com/Ensign-College/CSAI380FinalProject/blob/main/2.5-saving-the-data.md) | Redis and MySQL StatefulSets, headless services, secrets via secretKeyRef, persistence experiment | [CSAI380FinalProject](https://github.com/Ensign-College/CSAI380FinalProject) | ✅ VERIFIED 2026-10-15 |
| 3 | [3.4 ETL Skill Practice: Extract, Transform, Reconfigure](3.4-etl-airflow-practice.md) | Airflow DAGs, GCS object storage via Terraform, Helm values, DAG lint CI | [CSAI380-etl-airflow-starter](https://github.com/Ensign-College/CSAI380-etl-airflow-starter) | 🚧 DRAFT³ |
| 3 | [3.5 Block Project: Working ETL Pipeline](https://github.com/Ensign-College/CSAI380FinalProject/blob/main/3.5-working-etl-pipeline.md) | Airflow ETL DAG, pandas transform, idempotent load into MySQL, troubleshooting loop | [CSAI380FinalProject](https://github.com/Ensign-College/CSAI380FinalProject) | 🚧 DRAFT |
| 4 | [4.4 Kafka Skill Practice: Producer → Topic → Consumer](4.4-kafka-topics-practice.md) | Kafka via Helm, topics, producers, consumers, processing models | [CSAI380-kafka-topics-starter](https://github.com/Ensign-College/CSAI380-kafka-topics-starter) | 🚧 DRAFT³ |
| 4 | [4.5 Block Project: Streaming or Micro-batches](https://github.com/Ensign-College/CSAI380FinalProject/blob/main/4.5-streaming-or-micro-batches.md) | Kafka via Helm, `customer-risk` topic, producer/consumer round trip, processing models | [CSAI380FinalProject](https://github.com/Ensign-College/CSAI380FinalProject) | 🚧 DRAFT |
| 5 | [5.4 Scaling Skill Practice: Measure, Scale, Measure Again](5.4-scaling-hpa-practice.md) | Consumer groups, lag, GitOps replica scaling, HPA | [CSAI380-scaling-hpa-starter](https://github.com/Ensign-College/CSAI380-scaling-hpa-starter) | ✅ VERIFIED 2026-10-15 |
| 5 | [5.5 Block Project: Scaling and Downstream Integration](https://github.com/Ensign-College/CSAI380FinalProject/blob/main/5.5-scaling-and-downstream-integration.md) | Consumer lag, scaling experiment, idempotent upsert, analytical SQL, final architecture | [CSAI380FinalProject](https://github.com/Ensign-College/CSAI380FinalProject) | 🚧 DRAFT |

Each starter repo contains the exercise's student-facing files at the repo root, and its README links back to the assignment file here — edit instructions only in this repository; instructor solutions live on that repo's `solutions` branch at `solutions/README.md`. The N.5 Block Project assignments build the STEDI balance-device platform stage by stage and live in the [CSAI380FinalProject](https://github.com/Ensign-College/CSAI380FinalProject) repository.

¹ 1.4 Part Five changed 2026-10-29: students create their own `github-actions` service account and `GCP_SA_KEY` secret with gcloud; needs a live Actions run. Parts One–Four and Six were re-verified 2026-10-29 (us-central1 was out of capacity that day, so the test cluster was created in us-east1).

² 1.5 step 5.2 changed 2026-10-29 to reuse the 1.4 service-account key; needs a live Actions run. Everything else was re-verified 2026-10-29 with STEDI from the public [STEDI-Balance/stedi-web](https://github.com/STEDI-Balance/stedi-web) repository.

³ 3.4 and 4.4 changed 2026-10-29 to use the STEDI simulator ([starter/k8s/stedi-simulator.yaml](starter/k8s/stedi-simulator.yaml)) for signup events (3.4) and Kafka risk events (4.4); the simulator itself was tested locally with Docker, the exercises still need a GKE run. Previously verified 2026-10-15.
