# 1.4 Build, Deploy, and Explore — Teacher Notes

Verified 2026-10-15 against GKE Autopilot cluster (us-central1) in an instructor test project.

## Solutions

### Part One: Create the cluster

Verified 2026-10-29 (cluster created in us-east1 because us-central1 was out of capacity). Creation took about 4.5 minutes; `kubectl get nodes` returns `No resources found` until the first pod triggers an Autopilot scale-up.

```bash
gcloud services enable container.googleapis.com
gcloud container clusters create-auto <cluster-name> --region us-east1
gcloud container clusters get-credentials <cluster-name> --region us-east1
kubectl get nodes
```

### Part Two: Terraform

Working variable values (per student):

```hcl
# terraform.tfvars — never committed
project_id   = "<vocareum-project-id>"
region       = "us-east1"
student_name = "<github-username-lowercase>"
```

```bash
cd terraform
terraform init
terraform plan  -var-file=terraform.tfvars
terraform apply -var-file=terraform.tfvars
```

Expected outputs: `namespace`, `artifact_registry_url`, `raw_data_bucket`.

If students see `oauth2: "invalid_grant"`, their application-default credentials are stale:
`gcloud auth application-default login`, or export a token: `export GOOGLE_OAUTH_ACCESS_TOKEN=$(gcloud auth print-access-token)`.

### Part Three: busybox

```bash
sed 's/<your-namespace>/<ns>/' k8s/busybox-pod.yaml | kubectl apply -f -
kubectl get pods -n <ns>
kubectl describe pod busybox -n <ns>
kubectl logs busybox -n <ns>   # -> "BusyBox started"
```

### Part Four: image lifecycle (complete command set)

```bash
docker pull busybox:1.36                      # pull from Docker Hub
docker build --platform linux/amd64 -t hello-app:latest .
docker run --rm -p 8080:8080 -e STUDENT_NAME=me hello-app:latest
curl http://localhost:8080/                   # "Hello from me's container!"

AR=us-east1-docker.pkg.dev/<project>/<user>-images
gcloud auth configure-docker us-east1-docker.pkg.dev --quiet
docker tag hello-app:latest $AR/hello-app:latest
docker push $AR/hello-app:latest
docker rmi  $AR/hello-app:latest && docker pull $AR/hello-app:latest
```

### Part Six: Deployment and Service

After substituting `<your-namespace>`, `<your-name>`, and the image path:

```bash
kubectl apply -f k8s/deployment.yaml -f k8s/service.yaml
kubectl rollout status deploy/hello-app -n <ns>
# in-cluster check:
kubectl run curl-test -n <ns> --rm -i --restart=Never --image=busybox:1.36 -- \
  wget -qO- http://hello-app.<ns>.svc.cluster.local
# self-healing:
kubectl delete pod <one-hello-app-pod> -n <ns>   # replacement appears in ~10s
```

## Gotchas

| Symptom | Cause | Fix |
| --- | --- | --- |
| Pods crash-loop with `exec format error` | Image built on Apple Silicon (arm64); GKE nodes are amd64 | `docker build --platform linux/amd64 ...` |
| `oauth2: "invalid_grant"` from Terraform | Stale application-default credentials | `gcloud auth application-default login` |
| Autopilot warning `defaulted unspecified 'cpu' resource` | Autopilot injects resource defaults | Harmless; or set explicit requests as the starter manifests do |
| First rollout takes minutes | Autopilot provisioning a node | Wait; `kubectl get events -n <ns>` shows `TriggeredScaleUp` |
| `create-auto` fails: `Google Compute Engine does not have enough resources available to fulfill request: us-central1` | Regional capacity shortage (seen 2026-10-29) | Delete the cluster left in `ERROR` (`gcloud container clusters delete <cluster-name> --region <region>`), then retry later or create it in another region and use that region in `get-credentials`. The course moved to us-east1 after this shortage. |
| `kubectl logs` returns `No agent available` right after a pod starts | The new Autopilot node's connectivity agent is still starting | Wait ~30 seconds and retry |
| CI workflow fails on auth | `GCP_SA_KEY` secret missing/malformed | Repository secret must contain the full SA key JSON |

## Verification status

All steps executed successfully except Part Five (GitHub Actions run), which requires a classroom service-account key configured as a repo secret.
