# 2.4 Stateful Services: The Persistence Experiment — Teacher Notes

Verified 2026-10-15 against GKE Autopilot `autopilot-cluster-1` (us-central1), project `helpful-ally-451215-a3`.

## Solutions

### Round One: Redis without persistence (data loss is the point)

```bash
sed 's/<your-namespace>/<ns>/' k8s/stateful/redis-deployment.yaml | kubectl apply -f -
sed 's/<your-namespace>/<ns>/' k8s/stateful/redis-headless-service.yaml | kubectl apply -f -
kubectl rollout status deploy/redis -n <ns>

RPOD=$(kubectl get pods -n <ns> -l app=redis -o jsonpath='{.items[0].metadata.name}')
kubectl exec $RPOD -n <ns> -- redis-cli SET student:name "<name>"
kubectl exec $RPOD -n <ns> -- redis-cli KEYS '*'    # shows the key
kubectl delete pod $RPOD -n <ns>
kubectl rollout status deploy/redis -n <ns>
# new pod:
kubectl exec <new-pod> -n <ns> -- redis-cli KEYS '*'  # EMPTY — data gone
```

Expected answer: the container filesystem is ephemeral; the replacement pod starts from the image with no volume, so all keys are lost.

### Round Two: MySQL with PVC + Secret (data survives)

```bash
kubectl create secret generic mysql-credentials -n <ns> \
  --from-literal=root-password="$(openssl rand -base64 18)"
kubectl apply -f k8s/stateful/mysql-pvc.yaml -f k8s/stateful/mysql-deployment.yaml  # after sed
kubectl rollout status deploy/mysql -n <ns>   # 1–3 min: PVC bind + image pull

MPOD=$(kubectl get pods -n <ns> -l app=mysql -o jsonpath='{.items[0].metadata.name}')
kubectl exec $MPOD -n <ns> -- sh -c 'mysql -uroot -p"$MYSQL_ROOT_PASSWORD" csai380 -e \
  "CREATE TABLE IF NOT EXISTS persistence_test (id INT PRIMARY KEY, note VARCHAR(64));
   REPLACE INTO persistence_test VALUES (1, \"survived\");"'
kubectl delete pod $MPOD -n <ns>
kubectl rollout status deploy/mysql -n <ns>
# new pod:
kubectl exec <new-pod> -n <ns> -- sh -c 'mysql -uroot -p"$MYSQL_ROOT_PASSWORD" csai380 -e \
  "SELECT * FROM persistence_test;"'          # row returns: 1 | survived
```

Expected answer: the PVC (bound to a `standard-rwo` PersistentVolume) outlives the pod; the replacement mounts the same volume at `/var/lib/mysql`.

GKE default StorageClass observed: `standard-rwo`, access mode `ReadWriteOnce` (mountable read-write by a single node at a time — which is why the deployment uses `strategy: Recreate`).

## Gotchas

| Symptom | Cause | Fix |
| --- | --- | --- |
| MySQL rollout hangs with old+new pods | Default RollingUpdate deadlocks on an RWO volume | Starter manifest sets `strategy: Recreate` — keep it |
| `kubectl exec` mysql prompts for password | Shell quoting swallowed `$MYSQL_ROOT_PASSWORD` | Use single-quoted `sh -c '...'` so the var expands inside the pod |
| MySQL pod takes 1–3 min to start | PVC provisioning + ~200MB image pull on Autopilot | Expected; watch `kubectl get pvc,pods -n <ns>` |
| Secret missing error | Students applied the deployment before creating the secret | Create `mysql-credentials` first |

## Verification status

All steps executed successfully, both rounds, including data-loss and data-survival verification.
