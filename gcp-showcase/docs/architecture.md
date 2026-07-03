# Architecture

A three-tier "hello world" web app running on Google Kubernetes Engine, with
PostgreSQL managed by Cloud SQL.

```
                 Internet
                    │
            ┌───────▼────────┐
            │  Cloud Load     │   (L4, from the frontend Service type=LoadBalancer)
            │  Balancer (IP)  │
            └───────┬────────┘
                    │
        ┌───────────▼───────────┐   GKE cluster (VPC-native, private nodes)
        │  frontend (nginx)      │   namespace: showcase-<env>
        │  - serves static UI    │
        │  - proxies /api ──────►│
        └───────────┬───────────┘
                    │ ClusterIP
        ┌───────────▼───────────┐
        │  backend (Flask+gunicorn)
        │  - /health /ready      │
        │  - /api/hello          │
        │  - /api/messages (CRUD)│
        └───────────┬───────────┘
                    │ private IP (VPC peering)
        ┌───────────▼───────────┐
        │  Cloud SQL PostgreSQL  │
        └────────────────────────┘
```

## Components

| Tier | Technology | Notes |
|---|---|---|
| Frontend | nginx (unprivileged) + static HTML/JS | `type=LoadBalancer` Service → public IP; proxies `/api` to backend |
| Backend | Python Flask + gunicorn | REST API; lazy schema init on first DB access |
| Database | Cloud SQL for PostgreSQL 16 | Private IP only, reachable over VPC peering |
| Registry | Artifact Registry (Docker) | One repo per environment |
| Object store | Cloud Storage bucket | Versioned, uniform access, public access prevented |

## Environments

Five isolated environments — `dev`, `test`, `perf`, `staging`, `production` —
each a separate GKE cluster + Cloud SQL instance + Artifact Registry repo +
GCS bucket, described by the same Terraform with per-environment variables
(`production` gets a regional/HA database and larger nodes).
