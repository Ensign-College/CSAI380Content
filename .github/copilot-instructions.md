# Repository Instructions: CSAI 380 Exercise Authoring

This repository contains prototype Skill Practice assignments for CSAI 380 (AI Operations on GKE/GCP with Terraform and GitHub Actions). Follow these rules for all work in this repo.

## Core policy: tested or not done

- **We only publish exercises that we have tested and verified actually work.** An exercise is not done until every command, manifest, Terraform configuration, workflow, and DAG in it has been executed successfully against a real GKE/GCP environment.
- Every assignment file (`N.4-*.md`) must carry a status banner immediately below its title:
  - `🚧 DRAFT — not yet tested end-to-end` — instructions written, verification pending.
  - `✅ VERIFIED <YYYY-MM-DD>` — every step executed successfully; include the date and the environment (cluster/GCP project) it was verified against.
- Never flip a banner to VERIFIED without actually running the steps. Never remove a DRAFT banner as part of an unrelated edit.
- When an exercise changes, its status reverts to DRAFT until re-tested.

## Starter files

- Every file an exercise tells students to use, copy, or complete **must exist in this repository** under `starter/`, which mirrors the layout of the student repository:
  - `starter/terraform/` — Terraform for student-scoped resources (namespace, Artifact Registry, GCS bucket)
  - `starter/k8s/` — Kubernetes manifests (`stateful/`, `kafka/` subdirectories per week)
  - `starter/helm/` — Helm values files (Airflow, Kafka)
  - `starter/dags/` — Airflow DAGs
  - `starter/app/` + `starter/Dockerfile` — the sample application students containerize
  - `starter/.github/workflows/` — GitHub Actions workflows (kept under `starter/` so they do not execute in this repo)
- Placeholders students must replace are written as `<angle-brackets>` (e.g., `<your-namespace>`); TODOs students must implement are marked `# TODO(student):`.
- When an exercise references a starter file, link it by repo-relative path so the reference can be verified.

## Security rules for starter content

- Never commit credentials, service-account keys, tokens, or `.tfstate` files — the starter `.gitignore` must cover these.
- Secrets in manifests must use `secretKeyRef` / GitHub Actions secrets; never inline passwords, even as examples.
- Anything insecure-by-design for teaching (single-node MySQL, public load balancer) must say so explicitly in the exercise text.

## Conventions

- Assignments follow the W26 Canvas template: `# N.4 Title`, `## Purpose:`, `## Instructions:`, `## Grading` with a 15-point rubric (three criteria at 5/3/1/0).
- All student work is submitted as a GitHub repository link; exercises must keep the IaC + GitHub Actions thread consistent week to week.
- Flat file naming in repo root: `N.4-<slug>.md`.
