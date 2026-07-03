# GCP Cloud Native DevOps Showcase

A multi-tier "hello world" application (Flask API + PostgreSQL + nginx/static
frontend) with the Infrastructure as Code, Kubernetes manifests, CI/CD
pipelines, and docs to run it across five environments (`dev`, `test`, `perf`,
`staging`, `production`) on **Google Cloud** — GKE, Cloud SQL, Artifact
Registry, and Cloud Storage.

This is the GCP counterpart of an equivalent AWS (EKS/RDS/ECR/S3)
implementation; the application tier is identical and cloud-agnostic.

## Layout

```
gcp-showcase/
├── app/                  # multi-tier hello world app
│   ├── backend/          # Flask REST API (talks to Postgres)
│   ├── frontend/         # nginx + static HTML/JS
│   └── docker-compose.yml
├── terraform/            # Infrastructure as Code (GCP)
│   ├── modules/          # network, gke, cloudsql, artifact-registry, gcs
│   └── environments/     # dev, test, perf, staging, production
├── k8s/                  # Kubernetes manifests (Kustomize)
│   ├── base/             # Deployments, Services, ConfigMap, Secret, HPA
│   └── overlays/         # per-environment patches
└── docs/                 # architecture / infrastructure / pipeline
```

The two GitHub Actions pipelines live at the repository root under
`.github/workflows/`.

## Run it locally

```bash
cd gcp-showcase/app
docker compose up --build
# Frontend:       http://localhost:8080
# Backend health: http://localhost:5000/health
# Hello:          http://localhost:5000/api/hello
# Messages board: http://localhost:5000/api/messages
```

Backend tests:

```bash
cd gcp-showcase/app/backend
pip install -r requirements.txt
pytest
```

## Deploy the infrastructure

See [docs/infrastructure.md](docs/infrastructure.md). In short:

```bash
cd gcp-showcase/terraform/environments/dev
cp terraform.tfvars.example terraform.tfvars   # set project_id + a real db_password
terraform init
terraform apply -var-file=terraform.tfvars
```

## Deploy the app to GKE

```bash
gcloud container clusters get-credentials showcase-dev-gke --zone us-central1-a
# point kustomize at the images pushed to Artifact Registry, then:
kustomize build k8s/overlays/dev | kubectl apply -f -
kubectl -n showcase-dev get svc frontend   # EXTERNAL-IP serves the app
```

In CI this is the `deploy-gke` composite action — see
[docs/pipeline.md](docs/pipeline.md).

## Notes

- `terraform.tfvars` (real values) and Kubernetes secrets are not committed;
  only `.example`/placeholder versions are.
- Cloud SQL uses a **private IP**; the backend reaches it over VPC peering.
- The frontend is exposed with a `type=LoadBalancer` Service (L4 + public IP);
  a GKE Ingress + ManagedCertificate is the documented HTTPS path.
