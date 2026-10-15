# CSAI 380: AI Operations — Skill Practice Assignments

Prototype weekly Skill Practice assignments for CSAI 380 (AI infrastructure on GKE/GCP, with Terraform and GitHub Actions).

Exercises are only marked ✅ VERIFIED after every step has been executed against a real GKE/GCP environment — see [.github/copilot-instructions.md](.github/copilot-instructions.md). Student-facing starter files live in [starter/](starter/), mirroring the student repository layout.

## Table of Contents

| Week | Assignment | Topic | Starter repo | Status |
| ---- | ---------- | ----- | ------------ | ------ |
| 1 | [1.4 Build, Deploy, and Explore](1.4-build-deploy-explore.md) | Docker image lifecycle, GKE deployments and services, Terraform intro, GitHub Actions build/push | [CSAI380-build-deploy-starter](https://github.com/Ensign-College/CSAI380-build-deploy-starter) | ✅ VERIFIED 2026-10-15¹ |
| 2 | [2.4 Stateful Services: The Persistence Experiment](2.4-stateful-persistence-practice.md) | Redis/MySQL, PVs, PVCs, StorageClasses, StatefulSets, Secrets | [CSAI380-stateful-persistence-starter](https://github.com/Ensign-College/CSAI380-stateful-persistence-starter) | ✅ VERIFIED 2026-10-15 |
| 3 | [3.4 ETL Skill Practice: Extract, Transform, Reconfigure](3.4-etl-airflow-practice.md) | Airflow DAGs, GCS object storage via Terraform, Helm values, DAG lint CI | [CSAI380-etl-airflow-starter](https://github.com/Ensign-College/CSAI380-etl-airflow-starter) | ✅ VERIFIED 2026-10-15 |
| 4 | [4.4 Kafka Skill Practice: Producer → Topic → Consumer](4.4-kafka-topics-practice.md) | Kafka via Helm, topics, producers, consumers, processing models | [CSAI380-kafka-topics-starter](https://github.com/Ensign-College/CSAI380-kafka-topics-starter) | 🚧 DRAFT |
| 5 | [5.4 Scaling Skill Practice: Measure, Scale, Measure Again](5.4-scaling-hpa-practice.md) | Consumer groups, lag, GitOps replica scaling, HPA | [CSAI380-scaling-hpa-starter](https://github.com/Ensign-College/CSAI380-scaling-hpa-starter) | 🚧 DRAFT |
| 6 | [6.4 Block Project Self Review](6.4-block-project-self-review.md) | Rubric-based self assessment with repository evidence | [CSAI380-self-review-starter](https://github.com/Ensign-College/CSAI380-self-review-starter) | 🚧 DRAFT |
| 7 | [7.4 Final Demonstration Video](7.4-final-demo-video.md) | End-to-end demo, IaC walkthrough, live troubleshooting | — | 🚧 DRAFT |

Each starter repo contains the exercise's student-facing files at the repo root; instructor solutions live on that repo's `solutions` branch (currently 1.4 and 2.4).

¹ 1.4 verified except the GitHub Actions run, which awaits the classroom `GCP_SA_KEY` secret.
