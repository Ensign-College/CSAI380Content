# Repository Instructions: CSAI 380 Exercise Authoring

This repository contains prototype Skill Practice assignments for CSAI 380 (AI Operations on GKE/GCP with Terraform and GitHub Actions). Follow these rules for all work in this repo.

## Core policy: tested or not done

- **We only publish exercises that we have tested and verified actually work.** An exercise is not done until every command, manifest, Terraform configuration, workflow, and DAG in it has been executed successfully against a real GKE/GCP environment.
- Every assignment file (`N.4-*.md`) must carry a status banner immediately below its title:
  - `🚧 DRAFT — not yet tested end-to-end` — instructions written, verification pending.
  - `✅ VERIFIED <YYYY-MM-DD>` — every step executed successfully; include the date and the environment (cluster/GCP project) it was verified against.
- Never flip a banner to VERIFIED without actually running the steps. Never remove a DRAFT banner as part of an unrelated edit.
- When an exercise changes, its status reverts to DRAFT until the change has been tested.
- **You must test every change after making it.** After you edit an exercise, its starter files, or its solutions, execute the changed steps (and any later steps that depend on them) against a real GKE/GCP environment before you consider the change done. Leaving a changed exercise untested in DRAFT is not a substitute for testing it.
- If the re-test passes, update the banner to `✅ VERIFIED <YYYY-MM-DD>` with the environment. If you cannot run the test (for example, missing credentials or quota), say so explicitly, leave the banner at DRAFT, and note what still needs to be tested.

## Test environment and procedure

Testing is how an exercise earns `✅ VERIFIED`. Every agent working in this repository (Claude Code, Copilot, or other) follows this procedure.

**1. Before editing, check that you can test.** Run the preflight below. If any tool is missing, a credential fails, or the project is unreachable, **stop and ask the user** before making changes.

```bash
gcloud --version && terraform version && kubectl version --client && docker version && helm version
gcloud config get-value project          # expect the test project below
gcloud auth print-access-token >/dev/null && echo "gcloud auth OK"
gcloud auth application-default print-access-token >/dev/null && echo "Terraform (ADC) auth OK"
```

**2. Test environment.**

| Setting | Value |
| --- | --- |
| GCP project | `helpful-ally-451215-a3` |
| Region | `us-central1` |
| Shared verification cluster | `autopilot-cluster-1` (GKE Autopilot) |
| Login | `gcloud auth login` and `gcloud auth application-default login` |

- Run each exercise in its own verification namespace (for example `verify-1-4`, `verify-stedi`), never in `default`.
- Students create their own cluster in 1.4, so testing a change to cluster creation means creating a **temporary** Autopilot cluster (for example `verify-<YYYYMMDD>`) with the exercise's commands, then deleting it.

**3. Run the changed steps exactly as written for students,** plus every later step that depends on them. Use the student-facing commands and starter files, replacing only `<angle-bracket>` placeholders. If an exercise has a test script (`scripts/verify-N.N.sh`), run it; when you verify an exercise by hand, consider adding one.

**4. Record the result.** On success, update the status banner to `✅ VERIFIED <YYYY-MM-DD>` with the cluster and project, update the `README.md` table, and add any new gotchas to the teacher notes. On failure, fix and re-test. If you could not test, leave DRAFT and state in your final message what still needs testing.

**5. Clean up.** Delete temporary clusters and verification resources, or scale verification namespaces to zero, unless the user asks to keep them.

**6. Don't push or merge untested changes** to `main` in this repository or the starter repos; ask the user first.

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
- Each `CSAI380-*-starter` repo's README only links to its assignment file in this repository. Never copy instructions into a starter repo README; this repository is the single source of truth.

## Security rules for starter content

- **Never touch the `default` namespace.** It contains real (non-exercise) workloads and data. All exercise and verification resources live in dedicated namespaces (e.g., the student's username namespace, `verify-stedi`); never deploy to, scale, or delete anything in `default`.
- Never commit credentials, service-account keys, tokens, or `.tfstate` files — the starter `.gitignore` must cover these.
- Secrets in manifests must use `secretKeyRef` / GitHub Actions secrets; never inline passwords, even as examples.
- Anything insecure-by-design for teaching (single-node MySQL, public load balancer) must say so explicitly in the exercise text.

## Teacher notes and solutions

- When an exercise is finished (tested and verified), write teacher notes in a separate README under a `solutions/` directory, one subdirectory per exercise: `solutions/N.4/README.md`.
- Each solutions README must include:
  - **Solutions** — the completed commands, manifests, code, or configuration for every student-facing step, including completed versions of any `# TODO(student)` stubs.
  - **Gotchas** — pitfalls students may encounter, discovered during verification testing (e.g., Apple Silicon images crashing on amd64 nodes, GCE quota scale-up failures, chart key renames), each with its symptom and fix.
- Keep solutions out of `starter/` — students receive starter files, not solutions.

## Conventions

- Assignments follow the W26 Canvas template: `# N.4 Title`, `## Purpose:`, `## AI Ops in This Assignment:`, `## Instructions:`, `## Grading` with a 15-point rubric (three criteria at 5/3/1/0).
- **Every assignment must include an `## AI Ops in This Assignment:` section** (between `## Purpose:` and `## Instructions:`) reinforcing both senses of AI Operations: **(a) use an agent to do the ops** — a concrete, exercise-specific task where students use an agent with a defined goal and record the agent loop in their **AI Ops reflection**, and **(b) build infrastructure that AI operations run on** — a stated connection between the skill and running ML training, hosting models, and hosting applications connected to those models.
- All student work is submitted as a GitHub repository link; exercises must keep the IaC + GitHub Actions thread consistent week to week.
- Flat file naming in repo root: `N.4-<slug>.md`.
