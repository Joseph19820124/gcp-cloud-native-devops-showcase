# GitOps with Argo CD

This environment is delivered with **Argo CD** (pull-based GitOps): Argo CD runs
in the cluster, watches this repo, and continuously syncs the cluster to what
is declared under `k8s/overlays/<env>`. CI no longer runs `kubectl apply` — it
builds/pushes images and writes the new image tag back to git; Argo CD does the
deploy.

## What's here

- `application-dev.yaml` — the Argo CD `Application` for the dev environment.
  Points at `gcp-showcase/k8s/overlays/dev`, `automated` sync with `prune` +
  `selfHeal`.

## Install / bootstrap

```bash
# 1. Install Argo CD (server-side apply for the large CRDs)
kubectl create namespace argocd
kubectl apply -n argocd --server-side --force-conflicts \
  -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

# 2. Register the app
kubectl apply -f gcp-showcase/gitops/application-dev.yaml
```

## Secrets are NOT in git

The DB password is intentionally not committed. `k8s/base` no longer contains a
Secret; create it once per environment out-of-band (or, in production, generate
it with the External Secrets Operator from a secret manager):

```bash
kubectl -n showcase-dev create secret generic backend-secret \
  --from-literal=DB_PASSWORD='<the Cloud SQL password>'
```

Argo CD's `prune` only removes resources it manages, so this out-of-band Secret
is left untouched.

## Image updates

The `service-pipeline` builds and pushes images, then commits the new tag into
`k8s/overlays/dev/kustomization.yaml` (`images:`) with a `[skip ci]` message.
Argo CD detects the git change and rolls the deployment automatically.
