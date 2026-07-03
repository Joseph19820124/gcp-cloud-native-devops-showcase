# CI/CD Pipelines

Two GitHub Actions workflows live at the repository root under
`.github/workflows/` (GitHub only discovers workflows there), each scoped with
`paths:` filters to `gcp-showcase/**`.

## Service pipeline (`service-pipeline.yml`)

Triggered by changes under `app/**` or `k8s/**`.

1. **test** — installs deps and runs `pytest`.
2. **build-and-scan** — builds both images, scans with Trivy, and (on non-PR)
   authenticates to Google Cloud via **Workload Identity Federation** (no
   static keys) and pushes to Artifact Registry. Images are built once and
   promoted across environments by tag.
3. **deploy-dev → deploy-staging → deploy-production** — progressive rollout.
   Each uses the `deploy-gke` composite action, which gets GKE credentials,
   runs `kustomize edit set image` to pin the freshly built tags, applies the
   overlay, and waits for the rollout. `staging`/`production` map to GitHub
   Environments you can gate with required reviewers.

## Infra pipeline (`infra-pipeline.yml`)

Triggered by changes under `terraform/**`.

1. **fmt-validate** — `terraform fmt -check` + `validate` for all five envs.
2. **plan** — `terraform plan` per environment (matrix).
3. **apply** — on push to `main`, `terraform apply` per environment
   (serialized), each gated by its GitHub Environment.

## Setup required before pipelines run end-to-end

- A **Workload Identity Federation** pool/provider trusting this GitHub repo,
  and a deploy service account with roles for GKE, Artifact Registry, and
  Terraform-managed resources.
- Repo **variables**: `GCP_PROJECT`.
- Repo **secrets**: `GCP_WIF_PROVIDER`, `GCP_DEPLOY_SA`, `DB_PASSWORD`.
- The GCS state bucket (see [infrastructure.md](infrastructure.md)).
