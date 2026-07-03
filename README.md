# GCP Cloud Native DevOps Showcase

A multi-tier "hello world" application (Flask API + PostgreSQL + nginx/static
frontend) packaged with everything needed to run it across five environments
(`dev`, `test`, `perf`, `staging`, `production`) on **Google Cloud**:

- **App** — `gcp-showcase/app/` (Docker Compose locally, containers in the cloud)
- **Infrastructure as Code** — `gcp-showcase/terraform/` (VPC + Cloud NAT, GKE, Cloud SQL, Artifact Registry, GCS)
- **Kubernetes** — `gcp-showcase/k8s/` (Kustomize base + per-env overlays)
- **CI/CD** — `.github/workflows/` (infra pipeline + service pipeline, Workload Identity Federation)
- **Docs** — `gcp-showcase/docs/`

The application tier is identical to the equivalent AWS (EKS/RDS/ECR/S3)
implementation — only the infrastructure layer is cloud-specific. See
[`gcp-showcase/README.md`](gcp-showcase/README.md) for full instructions.

## Quick start (local)

```bash
cd gcp-showcase/app
docker compose up --build
# Frontend: http://localhost:8080   Backend: http://localhost:5000/health
```

## Verification status

Every layer was built and exercised — including a **real deployment to GCP**:

| Check | Result |
|---|---|
| Backend unit tests (`pytest`) | 3 passed |
| App end-to-end (`docker compose`) | frontend → API → Postgres all 200; messages persist |
| `terraform fmt -check` + `validate` (all 5 envs) | clean / valid |
| `kustomize build` (all 5 overlays) | renders correctly |
| **Terraform apply → GCP (dev)** | VPC + Cloud NAT, **GKE** (v1.35), **Cloud SQL** (private IP), Artifact Registry, GCS — all created |
| **Images → Artifact Registry** | backend + frontend pushed |
| **App deployed to GKE** | 2-node cluster, backend + frontend `Running`, exposed via `LoadBalancer` public IP |
| **Live end-to-end** | `GET /api/hello` → 200; `POST/GET /api/messages` persist to Cloud SQL |

The running app served `Hello, World! (env: dev)` and persisted messages
through the nginx frontend → Flask backend → Cloud SQL path.

### Notes from the real deployment

A few environment-specific things surfaced during the live run (documented so
they don't bite the next person):

- **Terraform ADC** defaulted to a service account without state-bucket access;
  ran Terraform with `GOOGLE_OAUTH_ACCESS_TOKEN` from the owner identity.
- **GCS bucket names are global** — the state bucket is suffixed with the
  project id to stay unique.
- **App robustness:** added a `connect_timeout` to the DB config — without it,
  an unreachable/misconfigured DB blocks gunicorn sync workers on the `/ready`
  probe until the liveness probe also times out and the pod restart-loops.
- At deploy time, the backend `DB_HOST` (Cloud SQL private IP) and the DB
  password Secret are injected from Terraform outputs — they are not committed.
