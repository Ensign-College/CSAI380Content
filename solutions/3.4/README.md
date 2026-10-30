# 3.4 ETL Skill Practice — Teacher Notes

Verified 2026-10-15 against GKE Autopilot cluster (us-central1) in an instructor test project. Part One re-verified 2026-10-29 with the new `us-east1` region default: the bucket is created in `US-EAST1`, and the extract solution's GCS client reads the uploaded CSV (249 rows).

## Solutions

### Part One: GCS bucket

`terraform apply` with [starter/terraform/gcs-bucket.tf](../../starter/terraform/gcs-bucket.tf); upload the source CSV:

```bash
curl -sL https://raw.githubusercontent.com/datasets/country-codes/main/data/country-codes.csv -o country-codes.csv
gcloud storage cp country-codes.csv gs://<project>-<user>-raw-data/
```

### Part Two: extract-phase solution (the `TODO(student)` stub)

```python
@task
def extract() -> dict:
    import csv
    import io
    import json

    import redis
    from google.cloud import storage

    blob = storage.Client().bucket(GCS_BUCKET).blob(COUNTRY_CSV_OBJECT)
    country_rows = list(csv.DictReader(io.StringIO(blob.download_as_text())))

    r = redis.Redis(host=REDIS_CONN_HOST, port=6379, decode_responses=True)
    signup_events = [json.loads(r.get(k)) for k in r.keys("signup:*")]

    return {"country_rows": country_rows, "signup_events": signup_events}
```

### Part Four: Airflow install / reconfigure

```bash
helm repo add apache-airflow https://airflow.apache.org
helm upgrade --install airflow apache-airflow/airflow -n <ns> -f helm/airflow-values.yaml --timeout 15m --wait
# verify the DAG registered via gitSync:
kubectl exec deploy/airflow-scheduler -n <ns> -c scheduler -- airflow dags list | grep csai380
```

Any change to `helm/airflow-values.yaml` is applied with the same `helm upgrade` command — that file, not the UI, is the source of truth.

## Gotchas

| Symptom | Cause | Fix |
| --- | --- | --- |
| All components stuck `Init:...`, migrations never run, `helm --wait` times out | Chart runs DB migrations as a Helm post-install hook, which `--wait` blocks forever | `migrateDatabaseJob.useHelmHooks: false` (already in starter values) |
| `FailedScaleUp: GCE quota exceeded`, pods Pending | Chart default resource requests exceed sandbox quota | Small per-component requests + `statsd.enabled: false` + `triggerer.enabled: false` (in starter values) |
| Pods Pending even with small component requests | **GKE Autopilot defaults every container without explicit requests to 500m/2Gi** — git-sync and log-groomer sidecars silently claim ~2 CPU/6Gi per Airflow pod | Explicit `resources` on `dags.gitSync`, each `logGroomerSidecar`, and `migrateDatabaseJob` (in starter values) |
| Triggerer Pending on `VolumeBinding` | Triggerer log PVC stalls on Autopilot | Triggerer is disabled entirely in starter values (`triggerer.enabled: false`) — no deferrable operators in this exercise |
| `webserver:` values ignored | Airflow 3 chart renamed the component | Use `apiServer:` |
| ruff fails on the starter DAG | Unused imports fail the exercise's own lint CI | Keep top-level imports minimal; import inside tasks |

## Verification status

Airflow 3 deployed from starter values; `csai380_etl_pipeline` registered via gitSync from this repo; bucket Terraform applied; DAG compiles and lints. Re-tested 2026-10-15 after quota right-sizing (log persistence off, metadata DB 2Gi, triggerer disabled, explicit sidecar/migration-job requests): fresh install converges with no Pending pods and no log PVCs. The full DAG run (extract→transform→load) requires the student's extract implementation plus Redis/MySQL connections, exercised in the block project.
