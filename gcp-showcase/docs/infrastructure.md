# Infrastructure (Terraform)

All infrastructure is declared as Terraform modules and instantiated per
environment. State lives in a GCS backend (one prefix per environment).

## Modules

| Module | Creates |
|---|---|
| `network` | VPC, subnet with secondary ranges (pods/services), Cloud Router + Cloud NAT, and Private Services Access (peering) for Cloud SQL private IP |
| `gke` | VPC-native GKE cluster (private nodes, public endpoint), a dedicated least-privilege node service account, and a managed node pool with autoscaling |
| `cloudsql` | Cloud SQL for PostgreSQL (private IP), a database, and an application user |
| `artifact-registry` | A Docker Artifact Registry repository with an untagged-image cleanup policy |
| `gcs` | A versioned, uniform-access Cloud Storage bucket with public access prevented |

## Environment sizing

| | dev / test / perf / staging | production |
|---|---|---|
| GKE nodes | 2 × `e2-medium` (autoscale 1–3) | 3 × `e2-medium` (autoscale 1–4) |
| Cloud SQL tier | `db-f1-micro` | `db-custom-1-3840` |
| Cloud SQL availability | `ZONAL` | `REGIONAL` (HA) |

## Deploy an environment

```bash
cd gcp-showcase/terraform/environments/dev
cp terraform.tfvars.example terraform.tfvars   # set project_id + a real db_password
terraform init
terraform apply -var-file=terraform.tfvars
```

### Backend bootstrap

The GCS state bucket referenced in `backend.tf` must exist first (globally
unique name):

```bash
gcloud storage buckets create gs://showcase-tfstate-<PROJECT> \
  --location us-central1 --uniform-bucket-level-access
gcloud storage buckets update gs://showcase-tfstate-<PROJECT> --versioning
```

### Credentials note

Terraform authenticates with Application Default Credentials. If your ADC
points at a service account without the needed roles, either grant that SA
`roles/owner` (or narrower), or run Terraform with your user identity:

```bash
export GOOGLE_OAUTH_ACCESS_TOKEN=$(gcloud auth print-access-token)
```
